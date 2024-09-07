import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_learner/state.dart';
import 'package:word_learner/words.dart';

import 'common.dart';
import 'word_list_widget.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

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

class SeparatorAskerDialog extends StatefulWidget {
  const SeparatorAskerDialog({super.key});

  @override
  State<SeparatorAskerDialog> createState() => _SeparatorAskerDialogState();
}

class _SeparatorAskerDialogState extends State<SeparatorAskerDialog> {
  String? dropdownValue = ",";

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: Border.all(),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("Separator: "),
                        DropdownButton(
                            value: dropdownValue,
                            items: const [
                              DropdownMenuItem(value: ",", child: Text(",")),
                              DropdownMenuItem(value: ";", child: Text(";")),
                              DropdownMenuItem(value: "\t", child: Text("Tab")),
                              DropdownMenuItem(value: "|", child: Text("|")),
                              DropdownMenuItem(value: "/", child: Text("/")),
                            ],
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                dropdownValue = value;
                              });
                            })
                      ]),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, dropdownValue);
                            },
                            child: const Text("OK")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"))
                      ])
                ])));
  }
}

Future<String?> askSeparator(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return const SeparatorAskerDialog();
      });
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  _OrderMode orderMode = _OrderMode.original;
  bool showPriors = false;

  @override
  bool get wantKeepAlive => true;

  void importBtnCb() async {
    final sep = await askSeparator(context);
    if (sep == null) {
      return;
    }

    assert(mounted);
    if (!mounted) return;
    final model = Provider.of<MainModel>(context, listen: false);
    FilePicker.platform
        .pickFiles(
      allowMultiple: false,
      type: FileType.any,
    )
        .then((value) {
      if (value != null &&
          value.files.isNotEmpty &&
          value.files[0].path != null) {
        List<Word> words = [];
        try {
          words =
              wordListRemoveDups(loadWordsOrThrow(value.files[0].path!, sep));
        } on FormatException catch (e) {
          showErrorDialog(context, "Failed to load wordlist", e.message);
        } on FileSystemException catch (e) {
          showErrorDialog(context, "Failed to load wordlist", e.message);
        }
        if (words.isNotEmpty) {
          showInfoSnackBar(context, "Loaded ${words.length} word pairs");
        }
        model.addCardsToActiveDeck(words);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = Provider.of<MainModel>(context);
    var deck = model.activeDeck;
    if (deck == null) {
      return const Center(child: Text("No deck open"));
    }

    var cards = [...deck.cards!];
    if (orderMode == _OrderMode.shuffled) {
      cards.shuffle();
    } else if (orderMode == _OrderMode.alphabet) {
      cards.sort(
          (a, b) => a.side1.toLowerCase().compareTo(b.side1.toLowerCase()));
    }

    var listWidget = deck.cards!.isNotEmpty
        ? WordListWidget(words: cards, showPriors: showPriors)
        : null;
    return Scaffold(
      appBar: AppBar(
        title: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, color: Colors.grey),
          onPressed: () {
            listWidget?.scrollToTop();
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
      body: listWidget ?? const Center(child: Text("Deck is empty")),
    );
  }
}
