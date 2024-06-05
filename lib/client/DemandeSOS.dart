import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CosulterDemande.dart'; // Import de la page ConsulterDemande.dart

class DemandeSOS extends StatefulWidget {
  @override
  _DemandeSOSState createState() => _DemandeSOSState();
}

class _DemandeSOSState extends State<DemandeSOS> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String prenom = '';
  String numeroTelephone = '';
  String typeVoiture = '';
  String positionVoiture = '';
  String tempsEnvoi = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  String heureRemorquage =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Appeler getNomPrenomFromPrefs() lors de l'initialisation de l'état
    getNomPrenomFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demande SOS'),
        backgroundColor: Colors.teal, // Couleur assortie pour l'AppBar
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    numeroTelephone = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Type de voiture',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le type de voiture';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    typeVoiture = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Position de voiture',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la position de la voiture';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    positionVoiture = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Heure de remorquage',
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                controller: TextEditingController(text: heureRemorquage),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        heureRemorquage = DateFormat('yyyy-MM-dd HH:mm:ss').format(
                          DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          ),
                        );
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 5),
                  Text(
                    'Temps d\'envoi : ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '$tempsEnvoi',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    envoyerDemande();
                  }
                },
                child: Text(
                  'Envoyer',
                  style: TextStyle(fontSize: 20.0),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal, // Couleur assortie pour le bouton
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getNomPrenomFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom') ?? '';
      prenom = prefs.getString('prenom') ?? '';
    });
  }

  void envoyerDemande() async {
    if (typeVoiture.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer le type de voiture')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    nom = prefs.getString('nom') ?? '';
    prenom = prefs.getString('prenom') ?? '';

    if (userId == null) {
      return;
    }

    // Convertir les chaînes de date en objets DateTime
    DateTime tempsEnvoiDate = DateFormat('dd/MM/yyyy HH:mm').parse(tempsEnvoi);
    DateTime heureRemorquageDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(heureRemorquage);

    // Vérifier si la date et l'heure de remorquage sont supérieures ou égales au temps d'envoi
    if (heureRemorquageDate.isBefore(tempsEnvoiDate)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur"),
            content: Text("La date et l'heure de remorquage doivent être supérieures ou égales au temps d'envoi."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer l'alerte
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    Map<String, dynamic> data = {
      "userId": userId,
      "nom": nom,
      "prenom": prenom,
      "NumTelephone": numeroTelephone,
      "TypeVoiture": typeVoiture,
      "PositionVoiture": positionVoiture,
      "heureRemorquage": heureRemorquage,
    };

    String url = 'http://10.0.2.2:8081/envoyerDemande';

    try {
     
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        int demandeId = responseData['demandeId'];

        await prefs.setInt('demandeId', demandeId);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Succès",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Couleur de succès
                ),
              ),
              content: Text(
                "Votre demande a été envoyée avec succès.",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer l'alerte
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConsulterDemande()),
                    );
                    viderFormulaire(); // Effacer le formulaire si nécessaire
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue, // Couleur du bouton OK
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi de la demande')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de la demande: $e')),
      );
    }
  }

  void viderFormulaire() {
    setState(() {
      nom = '';
      prenom = '';
      numeroTelephone = '';
      typeVoiture = '';
      positionVoiture = '';
    });
    _formKey.currentState!.reset();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Demande SOS',
    theme: ThemeData(
      primarySwatch: Colors.teal, // Couleur assortie pour le thème
    ),
    home: DemandeSOS(),
  ));
}
