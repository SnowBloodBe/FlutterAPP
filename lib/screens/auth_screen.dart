import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? Colors.red : Colors.white),
        ),
        backgroundColor: isError ? Colors.black : Colors.green,
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authService.signInWithEmail(email, password);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        _showMessage("Connexion réussie !");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage("Échec de connexion. Vérifiez vos informations.", isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage("Erreur : $e", isError: true);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authService.signUpWithEmail(email, password);
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        _showMessage("Compte créé avec succès !");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage("Échec de création de compte.", isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage("Erreur : $e", isError: true);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showMessage("Veuillez entrer votre email pour réinitialiser.", isError: true);
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      _showMessage("Email de réinitialisation envoyé !");
    } catch (e) {
      _showMessage("Erreur : $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFCC00), Color(0xFF002E6A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Affichage de l'image (Logo)
                        Image.network(
                          'https://drive.google.com/uc?export=view&id=1ABSqXVSH1JmSX06GEYjs2VGzmpCUxpIx',
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Impossible de charger l\'image',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bienvenue dans Golazo",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer un email valide.";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return "Format d'email invalide.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Le mot de passe ne peut pas être vide.";
                            }
                            if (value.length < 6) {
                              return "Le mot de passe doit contenir au moins 6 caractères.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Lien "Mot de passe oublié"
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 30),
                                ),
                                child: const Text(
                                  "Se connecter",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: _signUp,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 30),
                                ),
                                child: const Text(
                                  "Créer un compte",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
