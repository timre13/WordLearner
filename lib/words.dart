import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

const _INC_PRIO_VAL = 3;
const _DEC_PRIO_VAL = 3;

class Word {
  String side1;
  String side2;
  int _priority = 100;

  void incPriority() {
    _priority += _INC_PRIO_VAL;
  }

  void decPriority() {
    _priority -= _DEC_PRIO_VAL;
  }

  int get priority => _priority;

  Word(this.side1, this.side2);
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

int getRandomWordI(List<Word> words, [int lastVal = -1]) {
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
  if (i == lastVal) return getRandomWordI(words, lastVal);
  return i;
}
