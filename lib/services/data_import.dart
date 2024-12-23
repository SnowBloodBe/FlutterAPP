import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> importPlayersFromJson() async {
  try {
    final String jsonString = await rootBundle.loadString('lib/assets/data/joueurs.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Parcourir les données
    for (String difficulty in jsonData.keys) {
      // `difficulty` sera "Facile", "Moyen", ou "Difficile"
      List<dynamic> players = jsonData[difficulty];

      for (String player in players) {
        // Ajouter chaque joueur dans Firestore
        await firestore.collection('joueurs').add({
          'Nom': player,         // Nom du joueur
          'Niveau': difficulty,  // Niveau du joueur (Facile, Moyen, Difficile)
        });
      }
    }

    print("Données importées avec succès dans Firestore !");
  } catch (e) {
    print("Erreur lors de l'importation des données : $e");
  }
}
