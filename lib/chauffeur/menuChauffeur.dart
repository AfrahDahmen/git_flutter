import 'package:flutter/material.dart';
import 'ConsulterOffre.dart'; // Import de la page ConsulterOffre.dart
import 'ListeDemandes.dart'; // Import de la page ListeDemandes.dart

class MenuChauffeur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu Chauffeur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // Couleur teal pour l'AppBar
        elevation: 2.0,
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
                color: Colors.teal, // Couleur teal pour le titre
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Espacement entre le titre et les boutons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListeDemandes()),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Afficher liste demandes',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal, // Couleur teal pour le bouton
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
}
