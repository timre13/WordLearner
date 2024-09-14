import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';
import "package:sqlite3/sqlite3.dart" as sqlite;
import 'package:word_learner/words.dart';

import 'deck.dart';

class Database {
  late sqlite.Database _db;

  Database._createUninited();

  static Future<Database> create() async {
    if (kDebugMode) {
      print("Opening database");
    }

    var result = Database._createUninited();

    WidgetsFlutterBinding.ensureInitialized();
    var dirPath = (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    var filePath = path_pkg.join(dirPath?.path ?? "", "database.db");
    result._db = sqlite.sqlite3.open(filePath);
    result._initScheme();
    if (kDebugMode) {
      print("Opened database at $filePath");
    }
    return result;
  }

  void _initScheme() async {
    if (kDebugMode) {
      print("Initializing database");
    }

    _db.execute("""
      CREATE TABLE IF NOT EXISTS decks (
        id              INTEGER UNIQUE NOT NULL PRIMARY KEY,
        dateCreated     INTEGER NOT NULL,
        name            TEXT UNIQUE NOT NULL,
        description     TEXT
      )
    """);

    _db.execute("""
      CREATE TABLE IF NOT EXISTS cards (
        id              INTEGER UNIQUE NOT NULL PRIMARY KEY,
        deckId          INTEGER NOT NULL,
        frontSideText   TEXT NOT NULL,
        backSideText    TEXT NOT NULL,
        dateCreated     INTEGER NOT NULL,
        priority        INTEGER,
        FOREIGN KEY(deckId) REFERENCES decks(id)
      )
    """);

    if (false) {
      _db.prepare("""
      INSERT INTO decks (dateCreated, name, description)
      VALUES (?, ?, ?)
    """)
        ..execute([1234, "Deck #1", "Foo"])
        ..execute([5678, "Deck #2", "Bar"])
        ..execute([6245, "Deck #3", "Baz"])
        ..dispose();

      var stmt = _db.prepare("""
      INSERT INTO cards (deckId, frontSideText, backSideText, dateCreated)
      VALUES (?, ?, ?, ?)
    """);
      var rand = Random();
      for (var i = 0; i < 30; ++i) {
        final deck = rand.nextInt(3) + 1;
        stmt.execute([
          deck,
          "Card #$deck-${i + 1}A",
          "Card #$deck-${i + 1}B",
          rand.nextInt(1000)
        ]);
      }
      stmt.dispose();
    }

    if (kDebugMode) {
      print("Initialized database");
    }
  }

  void reset() {
    if (kDebugMode) {
      print("Clearing database");
    }

    _db.execute("DROP TABLE IF EXISTS decks");
    _db.execute("DROP TABLE IF EXISTS cards");
    if (kDebugMode) {
      print("Cleared database");
    }

    _initScheme();
  }

  void close() {
    _db.dispose();
    if (kDebugMode) {
      print("Closed database");
    }
  }

  List<Deck> loadDecks() {
    if (kDebugMode) {
      print("Loading decks");
    }

    sqlite.ResultSet queryResult;
    {
      var query =
          _db.prepare("SELECT id, dateCreated, name, description FROM decks");
      queryResult = query.select();
      query.dispose();
    }

    var result = queryResult
        .map(
          (row) => Deck(
              dbId: row["id"],
              dateCreated: DateTime.fromMillisecondsSinceEpoch(
                  (row["dateCreated"] as int) * 1000),
              name: row["name"] as String,
              description: row["description"] as String?),
        )
        .toList(growable: false);

    if (kDebugMode) {
      print("Loaded decks");
    }
    return result;
  }

  Future<void> loadCardsOfDeck(Deck deck) async {
    if (kDebugMode) {
      print("Loading cards of deck (id=${deck.dbId}, name=${deck.name})");
    }

    sqlite.ResultSet queryResults;
    {
      var query = _db.prepare("""
        SELECT id, frontSideText, backSideText, dateCreated, priority FROM cards
        WHERE deckId = ?
      """);
      queryResults = query.select([deck.dbId]);
      query.dispose();
    }
    deck.cards = [];
    for (final sqlite.Row row in queryResults) {
      deck.cards!.add(Word.withDbId(
        row["id"] as int,
        row["frontSideText"] as String,
        row["backSideText"] as String,
        DateTime.fromMillisecondsSinceEpoch((row["dateCreated"] as int) * 1000),
        row["priority"] as int?,
      ));
    }

    if (kDebugMode) {
      print("Loaded cards of deck");
    }
  }

  int getDeckCardCount(int deckId) {
    if (kDebugMode) {
      print("Getting card count for deck (id=$deckId)");
    }

    var query = _db.prepare("""
        SELECT COUNT(id) AS count FROM cards
        WHERE deckId = ?
      """);
    sqlite.ResultSet queryResults = query.select([deckId]);
    query.dispose();
    var result = queryResults[0]["count"];

    if (kDebugMode) {
      print("Got card count for deck");
    }
    return result;
  }

  void addCardsToDeck(int deckId, List<Word> cards) {
    var query = _db.prepare("""
        INSERT INTO cards (deckId, frontSideText, backSideText, dateCreated, priority)
        VALUES (?, ?, ?, ?, ?)
    """);
    for (final card in cards) {
      query.execute([
        deckId,
        card.side1,
        card.side2,
        card.dateCreated.millisecondsSinceEpoch ~/ 1000,
        (card.priority == 100 ? null : card.priority)
      ]);
    }
    query.dispose();
  }

  void createDeck(String name) {
    if (kDebugMode) {
      print("Creating new deck with name $name");
    }

    _db.prepare("""
        INSERT INTO decks (name, description, dateCreated)
        VALUES (?, '', ?)
    """)
      ..execute([name, DateTime.now().millisecondsSinceEpoch ~/ 1000])
      ..dispose();
  }

  bool doesDeckExist(String name) {
    if (kDebugMode) {
      print("Checking existence of deck with name $name");
    }

    var query = _db.prepare("""
      SELECT COUNT(id) AS count FROM decks WHERE name = ?
      """);
    sqlite.ResultSet queryResults = query.select([name]);
    query.dispose();
    var result = queryResults[0]["count"];
    assert(result == 0 || result == 1);
    return result == 1;
  }

  void deleteDeck(int dbId) {
    if (kDebugMode) {
      print("Deleting deck with DB ID $dbId");
    }

    _db.prepare("""
        DELETE FROM decks WHERE id = ?
    """)
      ..execute([dbId])
      ..dispose();

    _db.prepare("""
        DELETE FROM cards WHERE deckId = ?
    """)
      ..execute([dbId])
      ..dispose();
  }

  void renameDeck(int dbId, String newName) {
    if (kDebugMode) {
      print("Renaming deck with DB ID $dbId to $newName");
    }

    _db.prepare("""
        UPDATE decks
        SET name = ?
        WHERE id = ?
    """)
      ..execute([newName, dbId])
      ..dispose();
  }

  int getDeckCount() {
    if (kDebugMode) {
      print("Getting deck count");
    }

    var query = _db.prepare("""
        SELECT COUNT(id) AS count FROM decks
      """);
    sqlite.ResultSet queryResults = query.select();
    query.dispose();
    var result = queryResults[0]["count"];

    if (kDebugMode) {
      print("Got deck count");
    }
    return result;
  }

  void modifyCard(Word card) {
    if (kDebugMode) {
      print("Modifying card: $card");
    }

    // We want to modify an already existing card
    assert(card.dbId != null);

    var query = _db.prepare("""
      UPDATE cards
      SET frontSideText = ?, backSideText = ?, dateCreated = ?, priority = ?
      WHERE id = ?;
    """);
    query.execute([
      card.side1,
      card.side2,
      card.dateCreated.millisecondsSinceEpoch ~/ 1000,
      (card.priority == 100 ? null : card.priority),
      card.dbId
    ]);
    query.dispose();
  }
}
