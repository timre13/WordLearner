import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

class Word {
  String side1;
  String side2;
  int _priority = 100;

  void incPriority() {
    ++_priority;
  }

  void decPriority() {
    --_priority;
  }

  int get priority => _priority;

  Word(this.side1, this.side2);
}

List<Word> loadWords(String path) {
  if (kDebugMode) {
    print("Loading words from $path");
  }

  // TODO: Async
  var lines = File(path).readAsLinesSync();

  List<Word> words = [];
  for (var line in lines) {
    var cols = line.split(",");
    assert(cols.length == 2);
    words.add(Word(cols.elementAt(0), cols.elementAt(1)));
  }

  if (kDebugMode) {
    print("Loaded ${words.length} words");
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
