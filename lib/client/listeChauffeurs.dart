import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'DemandeSOS.dart';
import 'ProfileClient.dart'; // Import de la page ProfileClient.dart
import 'package:flutter_remorquage/login.dart'; // Import de la page de connexion

class ListeChauffeurs extends StatefulWidget {
  @override
  _ListeChauffeursState createState() => _ListeChauffeursState();
}

class _ListeChauffeursState extends State<ListeChauffeurs> {
  List<dynamic> chauffeurs = [];

  @override
  void initState() {
    super.initState();
    fetchChauffeurs();
  }

  Future<void> fetchChauffeurs() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/chauffeurs'));
    if (response.statusCode == 200) {
      setState(() {
        chauffeurs = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load chauffeurs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des chauffeurs'),
        backgroundColor: Colors.teal, // Couleur assortie pour l'AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showMenu(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chauffeurs.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(
                  '${chauffeurs[index]['nom']} ${chauffeurs[index]['prenom']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Couleur assortie pour le texte
                  ),
                ),
                onTap: () {
                  // Action à effectuer lors du clic sur un chauffeur
                  showDetailsDialog(
                    chauffeurs[index]['nom'],
                    chauffeurs[index]['prenom'],
                    chauffeurs[index]['NumTelephone'],
                    chauffeurs[index]['email'],
                    chauffeurs[index]['tempsEnvoi'] ?? 'Non disponible', // Utilisation de l'opérateur de coalescence nulle pour fournir une valeur par défaut
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DemandeSOS()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal, // Couleur assortie pour le bouton flottant
      ),
    );
  }

  void showDetailsDialog(String nom, String prenom, String numTelephone, String email, String timeSent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails du chauffeur',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Text('Nom: $nom', style: TextStyle(fontSize: 20.0)),
                Text('Prénom: $prenom', style: TextStyle(fontSize: 20.0)),
                Text('Numéro de téléphone: $numTelephone', style: TextStyle(fontSize: 20.0)),
                Text('Email: $email', style: TextStyle(fontSize: 20.0)),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Fermer',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person, color: Colors.teal),
                title: Text('Gestion de profil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileClient()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.teal),
                title: Text('Déconnecter'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
