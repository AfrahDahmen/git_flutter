import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_remorquage/client/home.dart';
import 'package:flutter_remorquage/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool chargement = false;
  final _formKey = GlobalKey<FormState>();
  var nom;
  var prenom;
  var NumTelephone;
  var email;
  var password;
  var role;
  var token = "";

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
                        "Inscription",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        hintText: "Nom",
                        icon: Icons.person,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entrez votre nom';
                          }
                          nom = value;
                          return null;
                        },
                      ),
                      _buildTextField(
                        hintText: "Prénom",
                        icon: Icons.person,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entrez votre prénom';
                          }
                          prenom = value;
                          return null;
                        },
                      ),
                      _buildTextField(
                        hintText: "Numéro de téléphone",
                        icon: Icons.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entrez votre numéro de téléphone';
                          }
                          if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                            return 'Le numéro de téléphone doit contenir 8 chiffres';
                          }
                          NumTelephone = value;
                          return null;
                        },
                      ),
                      _buildTextField(
                        hintText: "Email",
                        icon: Icons.email,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entrez votre email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Entrez un email valide';
                          }
                          email = value;
                          return null;
                        },
                      ),
                      _buildTextField(
                        hintText: "Mot de passe",
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entrez votre mot de passe';
                          }
                          if (value.length < 6 || value.length > 10) {
                            return 'Le mot de passe doit contenir entre 6 et 10 caractères';
                          }
                          password = value;
                          return null;
                        },
                      ),
                      _buildDropdown(),
                      SizedBox(height: 20),
                      _buildSubmitButton(),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          'Vous avez déjà un compte ? Connectez-vous',
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

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        style: TextStyle(color: Colors.teal[800]),
        value: role,
        icon: Icon(Icons.arrow_downward, color: Colors.teal[800]),
        iconSize: 24,
        elevation: 16,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: Colors.teal[800]),
          hintText: "Rôle",
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
        onChanged: (String? newValue) {
          setState(() {
            role = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Sélectionnez votre rôle';
          }
          return null;
        },
        items: <String>['Client', 'Chauffeur']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
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
          _register();
        }
      },
      child: Text(
        chargement ? 'Chargement...' : "S'inscrire",
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
    );
  }

  void _showAlert(String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(
          child: Text(
            'Message',
            style: TextStyle(
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.teal[800]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.teal[800]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      chargement = true;
    });
    var data = {
      'nom': nom,
      'prenom': prenom,
      'NumTelephone': NumTelephone,
      'email': email,
      'password': password,
      'role': role,
    };

    var res = await http.post(
      Uri.http('10.0.2.2:8081', '/signupUser'),
      body: jsonEncode(data),
      headers: _headers(),
    );

    if (res.body != null) {
      var body = json.decode(res.body);
      if (body.containsKey('success') && body['success'] != null) {
        if (body['success']) {
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          localStorage.setString('token', (body['data']['token']));
          localStorage.setString('NumTelephone', (body['data']['NumTelephone']));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      }
    }

    setState(() {
      chargement = false;
    });

    if (role == 'Chauffeur') {
      _showAlert('Attente activation');
    } else if (role == 'Client') {
      _showAlert('Compte activé');
    }
  }

  Map<String, String> _headers() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': ''
      };
}
