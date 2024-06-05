import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: ConsulterOffre(),
  ));
}

class ConsulterOffre extends StatefulWidget {
  @override
  _ConsulterOffreState createState() => _ConsulterOffreState();
}

class _ConsulterOffreState extends State<ConsulterOffre> {
  List<dynamic> offres = [];

  @override
  void initState() {
    super.initState();
    fetchOffres();
  }

  Future<void> fetchOffres() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/offre/$userId'));
    if (response.statusCode == 200) {
      setState(() {
        offres = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load offres');
    }
  }

  Future<void> deleteOffre(int? id) async {
    if (id != null) {
      try {
        final response = await http.delete(Uri.parse('http://10.0.2.2:8081/deleteOffre/$id'));
        if (response.statusCode == 200) {
          fetchOffres(); // Recharger la liste des offres après la suppression
        } else {
          throw Exception('Failed to delete offre');
        }
      } catch (error) {
        print('Error deleting offre: $error');
      }
    }
  }

  Future<void> fetchDemandeDetails(int? demandeId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8081/demande/details/$demandeId'));
      if (response.statusCode == 200) {
        Map<String, dynamic> demandeDetails = json.decode(response.body);
        // Afficher les détails de la demande dans une boîte de dialogue
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Détails de la demande"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Nom: ${demandeDetails['nom']}"),
                  Text("Prénom: ${demandeDetails['prenom']}"),
                  Text("Numéro de téléphone: ${demandeDetails['NumTelephone']}"),
                  Text("Type de voiture: ${demandeDetails['TypeVoiture']}"),
                  Text("Position de la voiture: ${demandeDetails['PositionVoiture']}"),
                  Text("Date d'envoi: ${demandeDetails['tempsEnvoi']}"),
                  Text("Heure de remorquage: ${demandeDetails['heureRemorage']}"),
                  // Ajoutez d'autres champs de détail de la demande selon votre structure de données
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text("Fermer"),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load demande details');
      }
    } catch (error) {
      print('Error fetching demande details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consulter Offres',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[900], // Couleur rouge pour l'AppBar
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white, // Fond blanc pour la page
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20), // Espacement entre le titre et la liste des offres
            Expanded(
              child: ListView.builder(
                itemCount: offres.length,
                itemBuilder: (BuildContext context, int index) {
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
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: offres[index]['etat'] == 0 ? Colors.orange : Colors.green,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'État: ${offres[index]['etat'] == 0 ? 'Non acceptée' : 'Acceptée'}',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Voulez-vous supprimer cette offre ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                            },
                                            child: Text("Non"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteOffre(offres[index]['id']);
                                              Navigator.of(context).pop(); // Fermer la boîte de dialogue après la suppression
                                            },
                                            child: Text("Oui"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red, // Couleur rouge pour le bouton
                                ),
                                child: Text('Supprimer'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Récupérer l'ID de la demande associée à cette offre
                                  int? demandeId = offres[index]['demandeId'];
                                  // Appeler la fonction pour afficher les détails de la demande
                                  fetchDemandeDetails(demandeId);
                                },
                                child: Text('Détails Demande'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
