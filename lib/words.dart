import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'main.dart';

const _INC_PRIO_VAL = 10;
const _DEC_PRIO_VAL = 1;

class Word {
  String side1;
  String side2;
  int _priority;

  void incPriority() {
    _priority += _INC_PRIO_VAL;
  }

  void decPriority() {
    _priority -= _DEC_PRIO_VAL;
  }

  int get priority => _priority;

  @override
  String toString() {
    return "Word('$side1', '$side2')";
  }

  Word(this.side1, this.side2, [int? priority]) : _priority = priority ?? 100;
}

List<Word> loadWordsOrThrow(String path) {
  if (kDebugMode) {
    print("Loading words from $path");
  }

  // TODO: Async
  var lines = File(path).readAsLinesSync();

  List<Word> words = [];
  for (var line in lines) {
    var cols = line.split(",");
    if (cols.length != 2) {
      throw const FormatException("CSV file has invalid format");
    }
    words.add(Word(cols.elementAt(0), cols.elementAt(1)));
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
