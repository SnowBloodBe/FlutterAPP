import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userEmail = "";
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            _userEmail = user.email ?? "";
            _gamesPlayed = userDoc['partiesJouees'] ?? 0;
            _gamesWon = userDoc['partiesGagnees'] ?? 0;
            _score = userDoc['score'] ?? 0;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        print("Erreur lors du chargement des statistiques utilisateur : $e");
      }
    }
  }

  void _navigateToGame() {
    Navigator.pushReplacementNamed(context, '/pendu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Affichez le logo
                Image.network(
                  'https://drive.google.com/uc?export=view&id=1ABSqXVSH1JmSX06GEYjs2VGzmpCUxpIx',
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Impossible de charger l\'image',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Affichez l'adresse email de l'utilisateur
                Text(
                  "Bienvenue chez Golazo, $_userEmail",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Statistiques de l'utilisateur
                const Text(
                  "Statistiques :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Parties jouées : $_gamesPlayed"),
                Text("Parties gagnées : $_gamesWon"),
                Text("Score : $_score"),
                const SizedBox(height: 30),
                // Bouton "Jouer"
                ElevatedButton(
                  onPressed: _navigateToGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Jouer",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
