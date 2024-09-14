import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:word_learner/settings.dart';

const incPrioVal = 10;
const decPrioVal = 1;

class Word {
  // Null if the card was created, non-null if the card was loaded from the database
  int? dbId;
  String side1;
  String side2;
  DateTime dateCreated;
  int _priority;

  void incPriority() {
    if (kDebugMode) {
      print(
          "Increasing priority of $this from $_priority to ${_priority + incPrioVal}");
    }
    _priority += incPrioVal;
  }

  void decPriority() {
    if (kDebugMode) {
      print(
          "Decreasing priority of $this from $_priority to ${_priority - decPrioVal}");
    }
    _priority -= decPrioVal;
  }

  int get priority => _priority;

  @override
  String toString() {
    return "Word('$side1', '$side2')";
  }

  Word(this.side1, this.side2, this.dateCreated, [int? priority])
      : _priority = priority ?? 100;

  Word.withDbId(int dbId_, this.side1, this.side2, this.dateCreated,
      [int? priority])
      : _priority = priority ?? 100,
        dbId = dbId_;
}

List<Word> loadWordsOrThrow(String path, String colSep) {
  if (kDebugMode) {
    print("Loading words from $path");
  }

  // TODO: Async
  var lines = File(path).readAsLinesSync();

  List<Word> words = [];
  var lineI = 1;
  for (var line in lines) {
    var cols = line.split(colSep);
    if (cols.length != 2) {
      throw FormatException(
          "CSV file has invalid format.\nLine $lineI has ${cols.length} columns.\nLine: \"$line\"");
    }
    words.add(Word(cols.elementAt(0), cols.elementAt(1), DateTime.now()));
    ++lineI;
  }

  if (kDebugMode) {
    print("Loaded ${words.length} words");
  }

  if (words.isEmpty) {
    throw const FormatException("The wordlist is empty");
  }

  return words;
}

List<Word> wordListRemoveDups(List<Word> words) {
  final ids = <int>{};
  return List<Word>.from(words)
    ..retainWhere((element) => ids.add(element.toString().hashCode));
}

List<Word> wordListSwapSides(List<Word> words) {
  return words
      .map((e) => Word(e.side2, e.side1, e.dateCreated, e._priority))
      .toList();
}

int _getRandomWordIWithPriority(List<Word> words, [int lastVal = -1]) {
  final sum = words.map((e) => e.priority).reduce((val, elem) => val + elem);
  int randomWeight = (Random().nextDouble() * sum).round();

  int i;
  for (i = 0; i < words.length; ++i) {
    randomWeight -= words.elementAt(i).priority;
    if (randomWeight <= 0) {
      break;
    }
  }
  // Retry
  if (i == lastVal) return _getRandomWordIWithPriority(words, lastVal);
  return i;
}

int _getRandomWordI(List<Word> words, [int lastval = -1]) {
  final random = (Random().nextDouble() * words.length).toInt();
  if (random == lastval) {
    return _getRandomWordI(words, lastval);
  }
  return random;
}

int _getNextWordIByOrder(List<Word> words, [int lastval = -1]) {
  final val = lastval + 1;
  if (val == words.length) return 0;
  return val;
}

int getNextWordI(OrderMode orderMode, List<Word> words, [int lastval = -1]) {
  assert(words.isNotEmpty);
  if (words.length == 1) return 0;
  switch (orderMode) {
    case OrderMode.randomPrio:
      return _getRandomWordIWithPriority(words, lastval);
    case OrderMode.random:
      return _getRandomWordI(words, lastval);
    case OrderMode.original:
      return _getNextWordIByOrder(words, lastval);
  }
}
