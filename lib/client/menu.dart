import 'package:flutter/material.dart';
import 'CosulterDemande.dart';
import 'listeChauffeurs.dart'; // Import de la page listeChauffeurs.dart
import 'DemandeSOS.dart'; // Import de la page DemandeSOS.dart
import 'ProfileClient.dart'; // Import de la page ProfileClient.dart
import 'package:flutter_remorquage/login.dart'; // Import de la page de connexion

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // Couleur assortie pour l'AppBar
        elevation: 2.0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showMenu(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200], // Fond gris clair pour la page
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue dans le menu', // Titre au-dessus des boutons
              style: TextStyle(
                fontSize: 28.0, // Taille de police plus grande
                fontWeight: FontWeight.bold,
                color: Colors.teal[800], // Couleur assortie pour le titre
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Espacement entre le titre et les boutons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListeChauffeurs()), // Navigation vers la page listeChauffeurs.dart
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Afficher liste chauffeurs', // Texte du bouton
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Couleur blanche pour le texte
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo, // Nouvelle couleur pour le bouton (indigo)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DemandeSOS()), // Navigation vers la page DemandeSOS.dart
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Envoyer Demande', // Texte du bouton
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Couleur blanche pour le texte
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange, // Nouvelle couleur pour le bouton (orange foncé)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConsulterDemande()), // Navigation vers la page ConsulterDemande.dart
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Consulter la demande', // Texte du bouton
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Couleur blanche pour le texte
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Nouvelle couleur pour le bouton (vert)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
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
