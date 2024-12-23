import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Identifiants pour un compte administrateur (à définir manuellement)
  final String _adminEmail = "admin@gmail.com";
  final String _adminPassword = "admin123";

  // Inscription avec email et mot de passe
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print('Le mot de passe est trop faible.');
          break;
        case 'email-already-in-use':
          print('Cet email est déjà utilisé.');
          break;
        case 'invalid-email':
          print('Email invalide.');
          break;
        default:
          print('Erreur FirebaseAuth : ${e.code}');
      }
      return null;
    } catch (e) {
      print("Erreur inconnue : $e");
      return null;
    }
  }

  // Connexion avec email et mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user; // Retourne l'utilisateur connecté
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('Utilisateur non trouvé.');
    } else if (e.code == 'wrong-password') {
      print('Mot de passe incorrect.');
    } else {
      print('Erreur FirebaseAuth : ${e.code}');
    }
    return null;
  } catch (e) {
    print("Erreur inconnue : $e");
    return null;
  }
}


  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("Déconnexion réussie.");
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
    }
  }

  // Vérifier l'état de l'utilisateur connecté
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Email de réinitialisation envoyé.");
    } catch (e) {
      print("Erreur lors de la réinitialisation du mot de passe : $e");
    }
  }

  // Vérifier si un utilisateur est connecté
  User? get currentUser => _auth.currentUser;

  // Création automatique d'un compte administrateur
  Future<void> createAdminAccount() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _adminEmail,
        password: _adminPassword,
      );
      print("Compte administrateur créé : ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Le compte administrateur existe déjà.");
      } else {
        print("Erreur lors de la création du compte administrateur : ${e.code}");
      }
    } catch (e) {
      print("Erreur inconnue lors de la création du compte administrateur : $e");
    }
  }
}
