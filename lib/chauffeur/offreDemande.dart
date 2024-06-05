import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'ListeDemandes.dart';  // Assurez-vous d'importer la page ListeDemandes

class OffreDemande extends StatefulWidget {
  final int demandeId;

  OffreDemande({required this.demandeId});

  @override
  _OffreDemandeState createState() => _OffreDemandeState();
}

class _OffreDemandeState extends State<OffreDemande> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDuree;  // Variable pour stocker la durée sélectionnée
  TextEditingController _prixController = TextEditingController();
  String tempsEnvoi = DateTime.now().toUtc().toIso8601String();  // Variable pour stocker le temps d'envoi en UTC

  Future<void> envoyerOffre() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/envoyerOffre/${widget.demandeId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'duree': _selectedDuree,  // Utiliser la durée sélectionnée
          'prix': _prixController.text,
          'userId': userId,
          'tempsEnvoi': tempsEnvoi,  // Ajouter le temps d'envoi ici
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _showSuccessDialog();  // Afficher l'alerte de succès
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi de l\'offre: ${error['error']}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text('Offre envoyée avec succès'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();  // Ferme l'alerte
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ListeDemandes()),
                );  // Navigue vers ListeDemandes
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoyer une Offre'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDuree,
                decoration: InputDecoration(labelText: 'Durée'),
                items: [
                  DropdownMenuItem(
                    value: "Entre 30 minutes et une heure",
                    child: Text("Entre 30 minutes et une heure"),
                  ),
                  DropdownMenuItem(
                    value: "Entre une heure et une heure et demi",
                    child: Text("Entre une heure et une heure et demi"),
                  ),
                  DropdownMenuItem(
                    value: "Entre une heure et demie et deux heures",
                    child: Text("Entre une heure et demie et deux heures"),
                  ),
                  DropdownMenuItem(
                    value: "Entre deux et trois heures",
                    child: Text("Entre deux et trois heures"),
                  ),
                  DropdownMenuItem(
                    value: "Plus de trois heures",
                    child: Text("Plus de trois heures"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDuree = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une durée';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixController,
                decoration: InputDecoration(labelText: 'Prix'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
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
                    '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().toLocal())}',  // Affiche le temps d'envoi en heure locale
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: envoyerOffre,
                child: Text('Envoyer', style: TextStyle(fontSize: 16.0)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
