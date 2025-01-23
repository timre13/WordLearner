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

class ImportOptionsDialogResult {
  String separator = ",";
  bool swapCols = false;
}

class ImportOptionsDialog extends StatefulWidget {
  const ImportOptionsDialog({super.key});

  @override
  State<ImportOptionsDialog> createState() => _ImportOptionsDialogState();
}

class _ImportOptionsDialogState extends State<ImportOptionsDialog> {
  var result = ImportOptionsDialogResult();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(shape: Border.all(), children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Separator: "),
                      DropdownButton(
                          value: result.separator,
                          items: const [
                            DropdownMenuItem(value: ",", child: Text(",")),
                            DropdownMenuItem(value: ";", child: Text(";")),
                            DropdownMenuItem(value: ":", child: Text(":")),
                            DropdownMenuItem(value: "\t", child: Text("Tab")),
                            DropdownMenuItem(value: "|", child: Text("|")),
                            DropdownMenuItem(value: "/", child: Text("/")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              result.separator = value!;
                            });
                          })
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Swap Columns: "),
                      Checkbox(
                          value: result.swapCols,
                          onChanged: (value) {
                            setState(() {
                              result.swapCols = value!;
                            });
                          })
                    ]),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, result);
                          },
                          child: const Text("OK")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"))
                    ])
              ]))
    ]);
  }
}

Future<ImportOptionsDialogResult?> askImportOptions(
    BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return const ImportOptionsDialog();
      });
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  _OrderMode orderMode = _OrderMode.original;
  bool showPriors = false;
  List<int> selectedItemIs = [];

  @override
  bool get wantKeepAlive => true;

  void importBtnCb() async {
    final opts = await askImportOptions(context);
    if (opts == null) {
      return;
    }

    selectedItemIs = [];

    assert(mounted);
    if (!mounted) return;
    final model = Provider.of<MainModel>(context, listen: false);
    final areFileExtsSupported = !Platform.isAndroid;
    FilePicker.platform
        .pickFiles(
            allowMultiple: false,
            type: areFileExtsSupported ? FileType.custom : FileType.any,
            allowedExtensions:
                areFileExtsSupported ? ["txt", "csv", "tsv"] : null)
        .then((value) {
      if (value != null &&
          value.files.isNotEmpty &&
          value.files[0].path != null) {
        List<Word> words = [];
        try {
          words = wordListRemoveDups(
              loadWordsOrThrow(value.files[0].path!, opts.separator));
          if (opts.swapCols) {
            words = wordListSwapSides(words);
          }
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
        ? WordListWidget(
            words: cards,
            showPriors: showPriors,
            selectedItemIs: selectedItemIs,
            onSelectionChanged: (selection) => selectedItemIs = selection)
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
                        selectedItemIs = [];
                        listWidget?.scrollToTop();
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
                        const PopupMenuDivider(),
                        PopupMenuItem(
                            onTap: () async {
                              assert(selectedItemIs.length == 1);
                              final newVal = await CardEditingDialog.show(
                                  context, cards[selectedItemIs[0]]);
                              if (newVal != null) {
                                assert(context.mounted);
                                if (!context.mounted) return;
                                final model = Provider.of<MainModel>(context,
                                    listen: false);
                                model.modifyCard(newVal);
                              }
                              setState(() {
                                selectedItemIs = [];
                              });
                            },
                            enabled: selectedItemIs.length == 1,
                            child: const Text("Edit Selected")),
                        PopupMenuItem(
                            onTap: () {
                              assert(selectedItemIs.isNotEmpty);
                              assert(context.mounted);
                              if (!context.mounted) return;
                              final model = Provider.of<MainModel>(context,
                                  listen: false);
                              model.deleteCards(
                                  selectedItemIs.map((e) => cards[e]).toList());
                              setState(() {
                                selectedItemIs = [];
                              });
                            },
                            enabled: selectedItemIs.isNotEmpty,
                            child: const Text("Delete Selected")),
                      ])
            ].cast<Widget>(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: listWidget ?? const Center(child: Text("Deck is empty")),
    );
  }
}
