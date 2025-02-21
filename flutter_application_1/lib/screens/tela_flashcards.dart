import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_deck.dart';

class flashcardScreen extends StatefulWidget {
  const flashcardScreen({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<flashcardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> decks = [];
  List<int> selectedDecks = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  void _loadDecks() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('decks')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      decks = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
          .toList();
    });
  }

  void _addDeck() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    TextEditingController _deckNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nome do Deck"),
          content: TextField(
            controller: _deckNameController,
            decoration: const InputDecoration(
              hintText: "Digite o nome do novo deck",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String deckName = _deckNameController.text.trim();
                if (deckName.isNotEmpty) {
                  DocumentReference newDeckRef = _firestore.collection('decks').doc();
                  await newDeckRef.set({
                    'name': deckName,
                    'userId': user.uid,
                  });
                  _loadDecks();
                }
                Navigator.of(context).pop();
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedDecks() async {
    if (selectedDecks.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Excluir Decks"),
          content: const Text("Tem certeza que deseja excluir os decks selecionados?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Excluir"),
              onPressed: () async {
                for (int index in selectedDecks) {
                  await _firestore.collection('decks').doc(decks[index]['id']).delete();
                }
                setState(() {
                  selectedDecks.clear();
                  isSelecting = false;
                });
                _loadDecks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedDecks.contains(index)) {
        selectedDecks.remove(index);
        if (selectedDecks.isEmpty) isSelecting = false;
      } else {
        selectedDecks.add(index);
      }
    });
  }

  void _startSelectionMode() {
    setState(() {
      isSelecting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        title: const Text(
          "Flashcards",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        actions: [
          if (isSelecting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedDecks,
              color: Colors.white,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              if (!isSelecting) _startSelectionMode();
              _toggleSelection(index);
            },
            onTap: () async {
              if (isSelecting) {
                _toggleSelection(index);
              } else {
                bool? updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(
                      deckId: decks[index]['id']!,
                      deckName: decks[index]['name']!,
                    ),
                  ),
                );
                if (updated == true) {
                  _loadDecks();
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: selectedDecks.contains(index)
                    ? Colors.grey[300]
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(decks[index]['name']!),
                trailing: isSelecting
                    ? Checkbox(
                        value: selectedDecks.contains(index),
                        onChanged: (bool? value) {
                          _toggleSelection(index);
                        },
                      )
                    : const Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeck,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
