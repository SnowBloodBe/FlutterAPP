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
       return const AuthScreen(); // Force l'écran d'authentification au démarrage

   
   /* return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {*/
        // Si l'utilisateur est connecté, affiche l'écran du jeu
       /* if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const PenduScreen();
          } else {
            return const AuthScreen();
          }
        }*/


        // Pendant le chargement
        /*return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );*/
  }
}
