// Import des packages nécessaires
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_remorquage/register.dart';
import 'package:flutter_remorquage/client/home.dart';
import 'package:flutter_remorquage/chauffeur/homeChauffeur.dart';

// Widget pour la page de connexion
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;

  // Méthode pour afficher une boîte de dialogue d'erreur
  _showMsg() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(
          child: Text(
            'ERREUR',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text('Login ou Mot de passe incorrect'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Connexion",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        hintText: "Email",
                        icon: Icons.email,
                        validator: (emailValue) {
                          if (emailValue!.isEmpty) {
                            return 'Entrer email';
                          }
                          email = emailValue;
                          return null;
                        },
                      ),
                      _buildTextField(
                        hintText: "Mot de passe",
                        icon: Icons.vpn_key,
                        obscureText: true,
                        validator: (passwordValue) {
                          if (passwordValue!.isEmpty) {
                            return 'Entrer mot de passe';
                          }
                          password = passwordValue;
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildSubmitButton(),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Bouton pour créer un nouveau compte
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ),
                          );
                        },
                        child: Text(
                          'Créer un nouveau compte',
                          style: TextStyle(
                            color: Colors.teal[800],
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        style: TextStyle(color: Colors.teal[800]),
        cursorColor: Colors.teal[800],
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal[800]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.teal[300]),
          filled: true,
          fillColor: Colors.teal[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal[800]!),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.teal[800],
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _login();
        }
      },
      child: Text(
        loading ? 'Chargement...' : 'Se connecter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
    );
  }

  // Méthode pour effectuer la connexion
  void _login() async {
    setState(() {
      loading = true;
    });
    var data = {'email': email, 'password': password};

    try {
      var res = await http.post(
        Uri.http('10.0.2.2:8081', '/loginUser'),
        body: jsonEncode(data),
        headers: _Headers(),
      );

      if (res.statusCode == 200) {
        var body = json.decode(res.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Sauvegarde des données dans SharedPreferences
        await prefs.setString('token', body["token"] ?? "");
        await prefs.setInt('userId', body["id"] ?? 0);
        await prefs.setString('nom', body["nom"] ?? "");
        await prefs.setString('prenom', body["prenom"] ?? "");
        await prefs.setString('email', body["email"] ?? "");
        await prefs.setString('numeroTelephone', body["numeroTelephone"] ?? "");

        // Redirection en fonction du rôle de l'utilisateur
        String role = (body["role"] ?? "").toLowerCase();
        if (role == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else if (role == 'chauffeur') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeChauffeur()),
          );
        } else {
          print('Rôle non reconnu');
        }
      } else {
        print('Erreur: ${res.reasonPhrase}');
        _showMsg();
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP: $e');
      _showMsg();
    }

    setState(() {
      loading = false;
    });
  }

  // Méthode pour les en-têtes de requête
  _Headers() => {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
}
