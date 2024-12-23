import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          // Afficher un indicateur de chargement
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Si un utilisateur est connecté
          debugPrint("Utilisateur connecté : ${snapshot.data?.email}");
          return const PenduScreen();
        } else {
          // Si aucun utilisateur n'est connecté
          debugPrint("Aucun utilisateur connecté, redirection vers AuthScreen.");
          return const AuthScreen();
        }
      },
    );
  }
}
