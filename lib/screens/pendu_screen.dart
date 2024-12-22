import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PenduScreen extends StatefulWidget {
  const PenduScreen({super.key});

  @override
  _PenduScreenState createState() => _PenduScreenState();
}

class _PenduScreenState extends State<PenduScreen> {
  final List<List<Map<String, dynamic>>> _guesses = [];
  final int _maxAttempts = 6;
  final TextEditingController _guessController = TextEditingController();
  final Map<String, Color> _keyboardColors = {
    for (var letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''))
      letter: Colors.grey,
  };

  String _targetWord = "";
  bool _gameOver = false;
  String _statusMessage = "Enter your guess";
  String _selectedDifficulty = "Facile";
  Map<String, List<String>> _wordOptions = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Récupérer les joueurs par niveau
      for (String difficulty in ["Facile", "Moyen", "Difficile"]) {
        QuerySnapshot snapshot = await firestore
            .collection('joueurs')
            .where('Niveau', isEqualTo: difficulty)
            .get();

        List<String> players = snapshot.docs
            .map((doc) => doc['Nom'].toString().toUpperCase())
            .toList();

        setState(() {
          _wordOptions[difficulty] = players;
        });
      }

      _setTargetWord();
      print("Les joueurs ont été chargés avec succès depuis Firestore !");
    } catch (e) {
      print("Erreur lors du chargement des joueurs depuis Firestore : $e");
    }
  }

  void _setTargetWord() {
    final words = _wordOptions[_selectedDifficulty] ?? [];
    if (words.isNotEmpty) {
      setState(() {
        _targetWord = (words..shuffle()).first.toUpperCase();
        _guesses.clear();
        _gameOver = false;
        _statusMessage = "Enter your guess";
        _guessController.clear();
        _keyboardColors
            .forEach((key, value) => _keyboardColors[key] = Colors.grey);
      });
    }
  }

  Future<void> _addUserToFirestore(User user) async {
  try {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'partiesJouees': 0,
      'partiesGagnees': 0,
      'score': 0,
    }, SetOptions(merge: true));

    print("Utilisateur ajouté à Firestore avec succès.");
  } catch (e) {
    print("Erreur lors de l'ajout de l'utilisateur à Firestore : $e");
  }
}


  Future<void> _updatePlayerStats(bool won) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Mettre à jour les statistiques pour cet utilisateur
        await userDoc.set({
          'partiesJouees': FieldValue.increment(1),
          'partiesGagnees':
              won ? FieldValue.increment(1) : FieldValue.increment(0),
          'score': FieldValue.increment(won ? 10 : 0),
        }, SetOptions(merge: true)); // Merge avec les données existantes

        // Utiliser setState si vous souhaitez mettre à jour l'interface locale
        setState(() {
          _statusMessage = won
              ? "Bravo ! Vous avez gagné la partie !"
              : "Dommage ! Vous avez perdu.";
        });

        print("Les statistiques de l'utilisateur ont été mises à jour.");
      } else {
        print(
            "Aucun utilisateur connecté. Impossible de mettre à jour les stats.");
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Erreur lors de la mise à jour des statistiques.";
      });
      print("Erreur lors de la mise à jour des statistiques : $e");
    }
  }

  void _addGuess(String guess) {
    if (guess.length != _targetWord.length) {
      setState(() {
        _statusMessage =
            "Your guess must be ${_targetWord.length} letters long.";
      });
      return;
    }

    List<Map<String, dynamic>> guessRow = [];
    for (int i = 0; i < _targetWord.length; i++) {
      final letter = guess[i].toUpperCase();
      if (_targetWord[i] == letter) {
        guessRow.add({"letter": letter, "color": Colors.green});
        _keyboardColors[letter] = Colors.green;
      } else if (_targetWord.contains(letter)) {
        guessRow.add({"letter": letter, "color": Colors.yellow});
        if (_keyboardColors[letter] != Colors.green) {
          _keyboardColors[letter] = Colors.yellow;
        }
      } else {
        guessRow.add({"letter": letter, "color": Colors.grey});
        if (_keyboardColors[letter] != Colors.green &&
            _keyboardColors[letter] != Colors.yellow) {
          _keyboardColors[letter] = Colors.grey;
        }
      }
    }

    setState(() {
    _guesses.insert(0, guessRow);
    _guessController.clear();

    if (guess == _targetWord) {
      _statusMessage = "Bravo ! Vous avez trouvé le mot $_targetWord !";
      _updatePlayerStats(true);
      _gameOver = true;
    } else if (_guesses.length >= _maxAttempts) {
      _statusMessage = "Dommage ! Le mot correct était $_targetWord.";
      _updatePlayerStats(false);
      _gameOver = true;
    } else {
      _statusMessage = "Essayez encore !";
    }
  });
  }

    void _resetGame() {
      _setTargetWord();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Jeu du Pendu")),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Niveau : "),
                      DropdownButton<String>(
                        value: _selectedDifficulty,
                        items: ["Facile", "Moyen", "Difficile"]
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedDifficulty) {
                            setState(() {
                              _selectedDifficulty = value;
                              _resetGame();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Le mot à deviner contient ${_targetWord.length} lettres.",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ..._guesses.map(
                    (guessRow) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: guessRow.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: entry["color"],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Text(
                                  entry["letter"],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ).toList(),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (!_gameOver)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _guessController,
                            decoration: const InputDecoration(
                              labelText: "Enter your guess",
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: _targetWord.isNotEmpty
                                ? _targetWord.length
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_gameOver) {
                                _addGuess(_guessController.text.toUpperCase());
                              }
                            },
                            child: const Icon(Icons.check),
                          ),
                        ),
                      ],
                    ),
                  if (_gameOver)
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text("Play Again"),
                    ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: _keyboardColors.keys.map((letter) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _keyboardColors[letter],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }