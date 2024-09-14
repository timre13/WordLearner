import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_learner/state.dart';
import 'package:word_learner/words.dart';

class WordListWidget extends StatefulWidget {
  WordListWidget({super.key, required this.words, required this.showPriors});

  final List<Word> words;
  final bool showPriors;
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
          return InkWell(
              child: Row(
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
                    ] +
                    (widget.showPriors
                        ? [
                            const VerticalDivider(width: 10),
                            Text(
                                widget.words
                                    .elementAt(index)
                                    .priority
                                    .toString(),
                                style: textStyle,
                                maxLines: 1),
                          ]
                        : []),
              ),
              onLongPress: () async {
                final newVal =
                    await CardEditingDialog.show(context, widget.words[index]);
                if (newVal != null) {
                  assert(context.mounted);
                  if (!context.mounted) return;
                  final model = Provider.of<MainModel>(context, listen: false);
                  model.modifyCard(newVal);
                }
              },
              onSecondaryTap: () async {
                final newVal =
                    await CardEditingDialog.show(context, widget.words[index]);
                if (newVal != null) {
                  assert(context.mounted);
                  if (!context.mounted) return;
                  final model = Provider.of<MainModel>(context, listen: false);
                  model.modifyCard(newVal);
                }
              });
        });
  }
}

class CardEditingDialog extends StatefulWidget {
  const CardEditingDialog({super.key, required this.word});

  final Word word;

  @override
  State<CardEditingDialog> createState() => _CardEditingDialogState();

  static Future<Word?> show(BuildContext context, Word word) async {
    return await showDialog(
        context: context, builder: (context) => CardEditingDialog(word: word));
  }
}

class _CardEditingDialogState extends State<CardEditingDialog> {
  late final TextEditingController _textEditController1;
  late final TextEditingController _textEditController2;

  @override
  void initState() {
    super.initState();

    _textEditController1 = TextEditingController(text: widget.word.side1);
    _textEditController2 = TextEditingController(text: widget.word.side2);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        shape: Border.all(),
        title: const Text("Edit Card"),
        contentPadding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _textEditController1, maxLines: null),
          TextField(controller: _textEditController2, maxLines: null),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          var newValue = widget.word;
                          newValue.side1 = _textEditController1.text.trim();
                          newValue.side2 = _textEditController2.text.trim();
                          Navigator.pop(context, newValue);
                        },
                        child: const Text("OK")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"))
                  ]))
        ]);
  }
}
