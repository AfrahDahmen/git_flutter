import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OffreDemande.dart'; // Import de la nouvelle page

void main() {
  runApp(MaterialApp(
    home: ListeDemandes(),
  ));
}

class ListeDemandes extends StatefulWidget {
  @override
  _ListeDemandesState createState() => _ListeDemandesState();
}

class _ListeDemandesState extends State<ListeDemandes> {
  List<dynamic> demandes = [];

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/demandes'));
    if (response.statusCode == 200) {
      setState(() {
        demandes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load demandes');
    }
  }

  void showOfferStatus(BuildContext context, int demandeId) async {
    try {
      // Supposez que le userId est stocké dans les SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non identifié')),
        );
        return;
      }

      final response = await http.get(Uri.parse('http://10.0.2.2:8081/offre/demande/$demandeId/$userId'));
      if (response.statusCode == 200) {
        final offers = json.decode(response.body) as List<dynamic>;
        if (offers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucune offre trouvée pour cette demande')),
          );
          return;
        }
        final offer = offers[0];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('État de l\'offre'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Durée d\'arrivée: ${offer['duree']}', style: TextStyle(fontSize: 16.0)),
                  Text('Prix: ${offer['prix']}', style: TextStyle(fontSize: 16.0)),
                  Text('Temps d\'envoi: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(offer['tempsEnvoi']))}', style: TextStyle(fontSize: 16.0)),
                  Text(
                    'État: ${offer['etat'] == 1 ? "Acceptée" : "Non acceptée"}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: offer['etat'] == 1 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Êtes-vous sûr de vouloir supprimer cette offre ?', style: TextStyle(fontSize: 16.0)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Annuler', style: TextStyle(fontSize: 16.0)),
                            ),
                            TextButton(
                              onPressed: () {
                                supprimerOffre(offer['id']);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('Supprimer', style: TextStyle(fontSize: 16.0)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer', style: TextStyle(fontSize: 16.0)),
                ),
              ],
            );
          },
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Erreur lors de la récupération de l\'offre')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void supprimerOffre(int offreId) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:8081/supprimerOffre/$offreId'));
      if (response.statusCode == 200) {
        print('Offre supprimée avec succès');
      } else {
        print('Erreur lors de la suppression de l\'offre: ${response.body}');
      }
    } catch (error) {
      print('Erreur lors de la suppression de l\'offre: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredDemandes = demandes.where((demande) => demande['etat'] <= 2).toList();
    filteredDemandes = filteredDemandes.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Demandes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: filteredDemandes.isEmpty
            ? Center(child: Text('Aucune demande à afficher'))
            : ListView.builder(
                itemCount: filteredDemandes.length,
                itemBuilder: (BuildContext context, int index) {
                  var etatDemande = '';
                  switch (filteredDemandes[index]['etat']) {
                    case 0:
                      etatDemande = 'Non traitée';
                      break;
                    case 1:
                      etatDemande = 'En cours';
                      break;
                    case 2:
                      etatDemande = 'Acceptée';
                      break;
                    case 3:
                      etatDemande = 'Terminée';
                      break;
                    default:
                      etatDemande = 'Inconnu';
                  }

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filteredDemandes[index]['nom']} ${filteredDemandes[index]['prenom']}',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          SizedBox(height: 8.0),
                          Text('Numéro de téléphone: ${filteredDemandes[index]['NumTelephone']}', style: TextStyle(fontSize: 16.0)),
                          Text('Type de voiture: ${filteredDemandes[index]['TypeVoiture']}', style: TextStyle(fontSize: 16.0)),
                          Text('Position de voiture: ${filteredDemandes[index]['PositionVoiture']}', style: TextStyle(fontSize: 16.0)),
                          Text('Heure de remorquage: ${filteredDemandes[index]['heureRemorquage']}', style: TextStyle(fontSize: 16.0)),
                          Text('Temps d\'envoi: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(filteredDemandes[index]['tempsEnvoi']))}', style: TextStyle(fontSize: 16.0)),
                          Text('État de la demande: $etatDemande', style: TextStyle(fontSize: 16.0)),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OffreDemande(demandeId: filteredDemandes[index]['id'])),
                                  );
                                },
                                child: Text('Envoyer Offre', style: TextStyle(fontSize: 16.0)),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  showOfferStatus(context, filteredDemandes[index]['id']);
                                },
                                child: Text('État Offre', style: TextStyle(fontSize: 16.0)),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.teal,
                                  onPrimary: Colors.white,
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
      ),
    );
  }
}
