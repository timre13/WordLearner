import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';
import "package:sqlite3/sqlite3.dart" as sqlite;
import 'package:word_learner/words.dart';

import 'deck.dart';

class Database {
  late sqlite.Database _db;

  Database._createUninited();

  static Future<Database> create() async {
    var result = Database._createUninited();

    WidgetsFlutterBinding.ensureInitialized();
    var dirPath = await getExternalStorageDirectory();

    var filePath = path_pkg.join(dirPath?.path ?? "", "database.db");
    result._db = sqlite.sqlite3.open(filePath);
    if (kDebugMode) {
      print("Opened database at $filePath");
    }
    return result;
  }

  void _initScheme() {
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

    _db.prepare("""
      INSERT INTO decks (dateCreated, name, description)
      VALUES (?, ?, ?)
    """)
      ..execute([1234, "Deck #1", "Foo"])
      ..execute([5678, "Deck #2", "Bar"])
      ..dispose();

    _db.prepare("""
      INSERT INTO cards (deckId, frontSideText, backSideText, dateCreated)
      VALUES (?, ?, ?, ?)
    """)
      ..execute([1, "Card #1.1 A", "Card #1.1 B", 1234])
      ..execute([1, "Card #1.2 A", "Card #1.2 B", 4322])
      ..execute([2, "Card #2.1 A", "Card #2.1 B", 7225])
      ..execute([2, "Card #2.2 A", "Card #2.2 B", 5423])
      ..dispose();
  }

  void reset() {
    if (kDebugMode) {
      print("Clearing database");
    }

    _db.execute("DROP TABLE IF EXISTS decks");
    _db.execute("DROP TABLE IF EXISTS cards");
    _initScheme();
  }

  void close() {
    _db.dispose();
    if (kDebugMode) {
      print("Closed database");
    }
  }

  List<Deck> loadDecks() {
    sqlite.ResultSet queryResult;
    {
      var query =
          _db.prepare("SELECT id, dateCreated, name, description FROM decks");
      queryResult = query.select();
      query.dispose();
    }

    return queryResult
        .map(
          (row) => Deck(
              dbId: row["id"],
              dateCreated: DateTime.fromMillisecondsSinceEpoch(
                  (row["dateCreated"] as int) * 1000),
              name: row["name"] as String,
              description: row["description"] as String?),
        )
        .toList(growable: false);
  }

  void loadCardsOfDeck(Deck deck) {
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
      deck.cards!.add(Word(
        row["frontSideText"] as String,
        row["backSideText"] as String,
        row["priority"] as int?,
      ));
    }
  }

  int getDeckCardCount(int deckId) {
    var query = _db.prepare("""
        SELECT COUNT(id) AS count FROM cards
        WHERE deckId = ?
      """);
    sqlite.ResultSet queryResults = query.select([deckId]);
    query.dispose();
    return queryResults[0]["count"];
  }
}
