import 'package:flutter/material.dart';
import 'package:word_learner/words.dart';

import 'word_list_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key, required this.cards}) : super(key: key);

  final List<Word> cards;

  @override
  State<ListPage> createState() => _ListPageState();
}

enum _OrderMode {
  original,
  shuffled,
  alphabet;

  toButtonLabel() {
    return ["Use original order", "Shuffle", "Sort alphabetically"][index];
  }

  IconData toButtonIcon() {
    return [Icons.sort, Icons.shuffle, Icons.sort_by_alpha][index];
  }
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  _OrderMode orderMode = _OrderMode.original;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.cards.isEmpty) {
      return const Center(child: Text("No list open"));
    }

    var cards = widget.cards.toList();
    if (orderMode == _OrderMode.shuffled) {
      cards.shuffle();
    } else if (orderMode == _OrderMode.alphabet) {
      cards.sort(
          (a, b) => a.side1.toLowerCase().compareTo(b.side1.toLowerCase()));
    }

    return Scaffold(
      appBar: AppBar(
        actions: _OrderMode.values
            .map((e) => IconButton(
                icon: Icon(e.toButtonIcon(),
                    color: (orderMode == e ? null : Colors.grey)),
                tooltip: e.toButtonLabel(),
                onPressed: () {
                  setState(() {
                    orderMode = e;
                  });
                }))
            .toList(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: WordListWidget(words: cards),
    );
  }
}
