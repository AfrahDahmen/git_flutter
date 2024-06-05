import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ListeOffre.dart';
import 'ProfileClient.dart'; // Import de la page ProfileClient.dart
import 'package:flutter_remorquage/login.dart'; // Import de la page de connexion

class ConsulterDemande extends StatefulWidget {
  @override
  _ConsulterDemandeState createState() => _ConsulterDemandeState();
}

class _ConsulterDemandeState extends State<ConsulterDemande> {
  List<dynamic> demandes = [];

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  Future<void> fetchDemandes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/demande/$userId'));
    if (response.statusCode == 200) {
      setState(() {
        demandes = json.decode(response.body);
        demandes = demandes.reversed.toList();
        if (demandes.isNotEmpty) {
          saveDemandeId(demandes.first['id']);
        }
      });
    } else {
      throw Exception('Failed to load demandes');
    }
  }

  Future<void> deleteDemande(int? id) async {
    if (id != null) {
      try {
        final response = await http.delete(Uri.parse('http://10.0.2.2:8081/deleteDemande/$id'));
        if (response.statusCode == 200) {
          fetchDemandes();
        } else {
          throw Exception('Failed to delete demande');
        }
      } catch (error) {
        print('Error deleting demande: $error');
      }
    }
  }

  Future<void> terminerDemande(int demandeId) async {
    final response = await http.put(Uri.parse('http://10.0.2.2:8081/demande/terminer/$demandeId'));
    if (response.statusCode == 200) {
      fetchDemandes(); // Mettre à jour la liste des demandes après la mise à jour
    } else {
      throw Exception('Failed to terminate demande');
    }
  }

  Future<void> saveDemandeId(int demandeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('demandeId', demandeId);
    print('Demande ID $demandeId has been saved.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulter Demandes'),
        backgroundColor: Colors.teal,
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
        itemCount: demandes.length,
        itemBuilder: (BuildContext context, int index) {
          // Vérifier si l'état de la demande est différent de 3 (Terminée)
          if (demandes[index]['etat'] != 3) {
            var tempsEnvoi = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(demandes[index]['tempsEnvoi']));
            var heureRemorquage = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(demandes[index]['heureRemorquage']));
            var etatDemande = '';
            switch (demandes[index]['etat']) {
              case 0:
                etatDemande = 'Non traité';
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
                      'Nom: ${demandes[index]['nom']}',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prénom: ${demandes[index]['prenom']}',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Numéro de téléphone: ${demandes[index]['NumTelephone']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Type de voiture: ${demandes[index]['TypeVoiture']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Position de voiture: ${demandes[index]['PositionVoiture']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Heure de remorquage: $heureRemorquage',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Temps d\'envoi: $tempsEnvoi',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'État de la demande: $etatDemande',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            saveDemandeId(demandes[index]['id']).then((_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ListeOffre()),
                              );
                            });
                          },
                          child: Text('Consulter les Offres'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (demandes[index]['etat'] == 2) // Condition pour afficher l'icône et le bouton
                          IconButton(
                            onPressed: () {
                              terminerDemande(demandes[index]['id']);
                            },
                            icon: Icon(Icons.done, color: Colors.green),
                          ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Voulez-vous supprimer cette demande ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Non"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteDemande(demandes[index]['id']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Oui"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Retourner un widget vide si l'état de la demande est Terminée
            return SizedBox.shrink();
          }
        },
      ),
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
