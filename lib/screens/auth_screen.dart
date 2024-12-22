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
  String _statusMessage = "";

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    var user = await _authService.signUpWithEmail(email, password);
    setState(() {
      _statusMessage = user != null
          ? "Inscription réussie !"
          : "Échec de l'inscription.";
    });
  }

  Future<void> _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    var user = await _authService.signInWithEmail(email, password);
    if (user != null) {
      setState(() {
        _statusMessage = "Connexion réussie !";
      });
      // Navigate to the main game screen
      Navigator.pushReplacementNamed(context, '/pendu');
      
    } else {
      setState(() {
        _statusMessage = "Échec de la connexion.";
      });
    }
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _statusMessage = "Veuillez entrer votre email pour réinitialiser le mot de passe.";
      });
      return;
    }

    await _authService.resetPassword(email);
    setState(() {
      _statusMessage = "Un email de réinitialisation a été envoyé si l'adresse est valide.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authentification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text("S'inscrire"),
            ),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text("Se connecter"),
            ),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text("Réinitialiser le mot de passe"),
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
