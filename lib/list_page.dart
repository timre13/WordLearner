import 'package:flutter/material.dart';
import 'package:word_learner/words.dart';

import 'word_list_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key, required this.cards}) : super(key: key);

  final List<Word> cards;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget w;
    if (widget.cards.isEmpty) {
      w = const Text("No list open");
    } else {
      w = WordListWidget(words: widget.cards);
    }
    return Center(child: w);
  }
}
