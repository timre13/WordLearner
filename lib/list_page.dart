import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:word_learner/main.dart';
import 'package:word_learner/words.dart';

import 'common.dart';
import 'word_list_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.cbs});

  final ListPageCallbacks cbs;

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
  bool showPriors = false;

  @override
  bool get wantKeepAlive => true;

  void importBtnCb() {
    const params =
        OpenFileDialogParams(dialogType: OpenFileDialogType.document);
    FlutterFileDialog.pickFile(params: params).then((value) {
      if (value != null) {
        List<Word> words = [];
        try {
          words = wordListRemoveDups(loadWordsOrThrow(value));
        } on FormatException catch (e) {
          showErrorDialog(context, "Failed to load wordlist", e.message);
        } on FileSystemException catch (e) {
          showErrorDialog(context, "Failed to load wordlist", e.message);
        }
        if (words.isNotEmpty) {
          showInfoSnackBar(context, "Loaded ${words.length} word pairs");
        }
        setState(() {
          widget.cbs.getActiveDeck()!.cards!.addAll(words);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.cbs.getActiveDeck() == null) {
      return const Center(child: Text("No list open"));
    }

    var cards = [...widget.cbs.getActiveDeck()!.cards!];
    if (orderMode == _OrderMode.shuffled) {
      cards.shuffle();
    } else if (orderMode == _OrderMode.alphabet) {
      cards.sort(
          (a, b) => a.side1.toLowerCase().compareTo(b.side1.toLowerCase()));
    }

    var listWidget = WordListWidget(words: cards, showPriors: showPriors);
    return Scaffold(
      appBar: AppBar(
        title: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, color: Colors.grey),
          onPressed: () {
            listWidget.scrollToTop();
          },
        ),
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
                .toList(growable: false)
                .cast<Widget>() +
            [
              PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry>[
                        CheckedPopupMenuItem(
                          checked: showPriors,
                          onTap: () {
                            setState(() {
                              showPriors = !showPriors;
                            });
                          },
                          child: const Text("Show Priority"),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          onTap: importBtnCb,
                          child: const Text("Import Cards"),
                        ),
                      ])
            ].cast<Widget>(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: listWidget,
    );
  }
}
