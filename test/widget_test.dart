// Ce fichier est généré automatiquement par Flutter pour tester votre widget principal.

import 'package:flutter_test/flutter_test.dart';
import 'package:pendu_firebase/main.dart'; // Assurez-vous que le chemin est correct

void main() {
  testWidgets('Test de base pour PenduJeuApp', (WidgetTester tester) async {
    // Construire le widget PenduJeuApp et déclencher un frame.
    await tester.pumpWidget(const PenduJeuApp());

    // Vérifier que le widget AuthScreen est chargé (ou tout autre widget de démarrage que vous utilisez).
    expect(find.text('Connexion'), findsOneWidget); // Modifiez le texte si nécessaire
  });
}
