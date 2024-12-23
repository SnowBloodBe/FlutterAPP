import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pendu_firebase/screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/pendu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PenduJeuApp());
}

class PenduJeuApp extends StatelessWidget {
  const PenduJeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu du Pendu',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/pendu': (context) => const PenduScreen(),
        '/home': (context) => const HomeScreen(), // Ajoute cette ligne
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Si un utilisateur est connecté
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/home'); // Redirection vers HomeScreen
          });
        } else {
          // Si aucun utilisateur n'est connecté
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/auth'); // Redirection vers AuthScreen
          });
        }

        // Retourne un widget temporaire vide pour éviter les erreurs
        return const SizedBox.shrink();
      },
    );
  }
}

