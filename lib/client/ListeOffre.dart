import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CosulterDemande.dart'; // Importez la page ConsulteDemande

class ListeOffre extends StatefulWidget {
  @override
  _ListeOffresState createState() => _ListeOffresState();
}

class _ListeOffresState extends State<ListeOffre> {
  List<dynamic> offres = [];
  bool _offreAcceptee = false; // Garder une trace de l'état de l'offre
  bool _isLoading = true; // Garder une trace de l'état du chargement
  String _errorMessage = ''; // Garder une trace des erreurs

  @override
  void initState() {
    super.initState();
    fetchOffres();
  }

  Future<void> fetchOffres() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? demandeId = prefs.getInt('demandeId');

    if (demandeId != null) {
      final url = Uri.parse('http://10.0.2.2:8081/offre/demande/$demandeId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          offres = json.decode(response.body);
          _offreAcceptee = offres.any((offre) => offre['etat'] == 1); // Vérifier si une offre est déjà acceptée
          _isLoading = false; // Terminer le chargement
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load offres';
          _isLoading = false; // Terminer le chargement
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Demande ID non disponible';
        _isLoading = false; // Terminer le chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Offres'),
        backgroundColor: Colors.teal, // Couleur assortie pour l'AppBar
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                )
              : offres.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune offre trouvée pour cette demande',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: offres.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool offreAcceptee = offres[index]['etat'] == 1;
                        DateTime tempsEnvoiUtc = offres[index]['tempsEnvoi'] != null ? DateTime.parse(offres[index]['tempsEnvoi']) : DateTime.now();
                        String tempsEnvoiLocal = DateFormat('dd/MM/yyyy HH:mm').format(tempsEnvoiUtc.toLocal());

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Durée: ${offres[index]['duree']}',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                Text(
                                  'Prix: ${offres[index]['prix']}',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                Text(
                                  'Temps d\'envoi: $tempsEnvoiLocal',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        getUserDetails(offres[index]['userId']);
                                      },
                                      child: Text('Détails'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blue, // Couleur bleue pour le bouton
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _offreAcceptee || offreAcceptee // Désactiver le bouton si une offre est déjà acceptée
                                          ? null
                                          : () {
                                              accepterOffre(offres[index]['id']);
                                            },
                                      child: Text(offreAcceptee ? 'Déjà acceptée' : 'Accepter'),
                                      style: ElevatedButton.styleFrom(
                                        primary: offreAcceptee ? Colors.grey : Colors.green, // Couleur verte pour le bouton
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Future<void> getUserDetails(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/user/$userId'));
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Détails de l\'utilisateur'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nom: ${userData['nom']}'),
                Text('Prénom: ${userData['prenom']}'),
                Text('Numéro de téléphone: ${userData['NumTelephone']}'),
                Text('Email: ${userData['email']}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fermer'),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<void> accepterOffre(int offreId) async {
    final response = await http.put(Uri.parse('http://10.0.2.2:8081/offre/accepter/$offreId'));
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Succès'),
            content: Text('Offre acceptée avec succès'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page ConsulteDemande après avoir cliqué sur OK
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ConsulterDemande()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      fetchOffres(); // Recharger la liste des offres après l'acceptation
      setState(() {
        _offreAcceptee = true; // Marquer l'offre comme acceptée localement
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de l\'acceptation de l\'offre'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
