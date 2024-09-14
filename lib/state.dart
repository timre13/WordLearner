import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:word_learner/words.dart';

import 'database.dart';
import 'deck.dart';

class MainModel extends ChangeNotifier {
  final Database _db;
  int _activeDeckI = -1;

  MainModel({required Database db}) : _db = db;

  // ---------- Getters ----------

  UnmodifiableListView<Deck> get decks {
    final decks = _db.loadDecks();
    for (var d in decks) {
      if (d.cards == null) {
        _db.loadCardsOfDeck(d);
      }
    }
    return UnmodifiableListView(decks);
  }

  int get deckCount => _db.getDeckCount();

  int get activeDeckI => _activeDeckI;

  Deck? get activeDeck => (_activeDeckI < 0 || _activeDeckI >= deckCount)
      ? null
      : decks[_activeDeckI];

  bool doesDeckExist(String name) => _db.doesDeckExist(name);

  // ---------- Setters ----------

  void createDeck(name) {
    _db.createDeck(name);
    // Select the new deck
    _activeDeckI = deckCount - 1;
    notifyListeners();
  }

  void deleteDeck(i) {
    _db.deleteDeck(decks[i].dbId);
    _activeDeckI = -1;
    notifyListeners();
  }

  void renameDeck(i, String newName) {
    _db.renameDeck(decks[i].dbId, newName);
    notifyListeners();
  }

  set activeDeckI(int val) {
    _activeDeckI = val;
    notifyListeners();
  }

  void incCardPriority(int index) {
    final deck = activeDeck;
    if (deck == null) return;
    // TODO: Save card priority
    deck.cards![index].incPriority();
    notifyListeners();
  }

  void decCardPriority(int index) {
    final deck = activeDeck;
    if (deck == null) return;
    // TODO: Save card priority
    deck.cards![index].decPriority();
    notifyListeners();
  }

  void addCardsToActiveDeck(List<Word> cards) {
    if (activeDeck == null) return;
    _db.addCardsToDeck(activeDeck!.dbId, cards);
    notifyListeners();
  }

  void modifyCard(Word card) {
    _db.modifyCard(card);
    notifyListeners();
  }
}
