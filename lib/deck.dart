import 'package:word_learner/words.dart';

class Deck {
  int dbId;
  DateTime dateCreated;
  String name;
  String? description;
  List<Word>? cards;

  Deck(
      {required this.dbId,
      required this.dateCreated,
      required this.name,
      required this.description});
}
