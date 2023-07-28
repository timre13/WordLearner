import 'package:flutter/material.dart';
import 'package:word_learner/words.dart';

class WordListWidget extends StatefulWidget {
  WordListWidget({Key? key, required this.words}) : super(key: key);

  final List<Word> words;
  final _scrollController = ScrollController();

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  @override
  State<WordListWidget> createState() => _WordListWidgetState();
}

class _WordListWidgetState extends State<WordListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: widget._scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        separatorBuilder: (context, index) =>
            Divider(color: Colors.cyan.withAlpha(150)),
        itemCount: widget.words.length,
        itemBuilder: (context, index) {
          final textStyle = TextStyle(
              color: (index % 2 == 1 ? Colors.cyan.shade300 : Colors.white));
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 1,
                  child: Text(widget.words.elementAt(index).side1,
                      style: textStyle, maxLines: 2)),
              const VerticalDivider(width: 10),
              Expanded(
                  flex: 1,
                  child: Text(widget.words.elementAt(index).side2,
                      style: textStyle, maxLines: 2)),
            ],
          );
        });
  }
}
