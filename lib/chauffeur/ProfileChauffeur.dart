import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileChauffeur extends StatefulWidget {
  @override
  _ProfileChauffeurState createState() => _ProfileChauffeurState();
}

class _ProfileChauffeurState extends State<ProfileChauffeur> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _numTelephoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId') ?? 0;
    if (_userId != 0) {
      _fetchUserProfile();
    }
  }

  _fetchUserProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      var res = await http.get(Uri.http('10.0.2.2:8081', '/user/$_userId'));
      if (res.statusCode == 200) {
        var userData = json.decode(res.body);
        setState(() {
          _nomController.text = userData['nom'];
          _prenomController.text = userData['prenom'];
          _numTelephoneController.text = userData['NumTelephone'];
          _emailController.text = userData['email'];
          _passwordController.text = userData['password'];  // Assurez-vous que votre API renvoie le mot de passe
        });
      } else {
        print('Erreur: ${res.reasonPhrase}');
      }
    } catch (e) {
      print('Erreur lors de la requête HTTP: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      var data = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'NumTelephone': _numTelephoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        var res = await http.put(
          Uri.http('10.0.2.2:8081', '/updateUser/$_userId'),
          body: jsonEncode(data),
          headers: {'Content-type': 'application/json', 'Accept': 'application/json'},
        );

        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profil mis à jour avec succès!'),
          ));
        } else {
          print('Erreur: ${res.reasonPhrase}');
        }
      } catch (e) {
        print('Erreur lors de la requête HTTP: $e');
      }

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2.0,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    _buildTextField(_nomController, 'Nom', Icons.person),
                    SizedBox(height: 20),
                    _buildTextField(_prenomController, 'Prénom', Icons.person_outline),
                    SizedBox(height: 20),
                    _buildTextField(_numTelephoneController, 'Numéro de téléphone', Icons.phone),
                    SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email', Icons.email),
                    SizedBox(height: 20),
                    _buildTextField(_passwordController, 'Mot de passe', Icons.lock, obscureText: true),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _updateUserProfile,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.save, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.teal,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.teal,
            width: 2.0,
          ),
        ),
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le $labelText';
        }
        return null;
      },
    );
  }
}
