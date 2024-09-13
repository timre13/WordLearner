import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:word_learner/TextDialog.dart";
import 'package:word_learner/common.dart';
import 'package:word_learner/state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final scrollCtrl = ScrollController();
    final model = Provider.of<MainModel>(context);

    return Center(
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Word Learner", textScaler: TextScaler.linear(2))),
          Wrap(
              direction: Axis.horizontal,
              spacing: 15,
              runSpacing: 5,
              children: [
                HomePageButton(
                  icon: Icons.file_open,
                  label: "Create deck...",
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const TextDialog(
                          title: "Create Deck",
                          fieldText: "Deck name")).then((listName) {
                    if (listName == null) {
                      return;
                    }
                    if (model.doesDeckExist(listName)) {
                      showErrorDialog(context, "Error Creating Deck",
                          "Deck with name \"$listName\" already exists");
                      return;
                    }
                    model.createDeck(listName);
                    scrollCtrl.animateTo(
                        scrollCtrl.position.maxScrollExtent + 100,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                  }),
                ),
                HomePageButton(
                  icon: Icons.edit,
                  label: "Rename deck...",
                  onPressed: () async {
                    if (model.activeDeckI == -1) {
                      showErrorDialog(
                          context, "Failed to rename", "No selected deck");
                      return;
                    }

                    var newName = await showDialog(
                        context: context,
                        builder: (context) => const TextDialog(
                            title: "Rename Deck", fieldText: "Deck name"));
                    if (newName == null) {
                      return;
                    }

                    model.renameDeck(model.activeDeckI, newName);

                    scrollCtrl.animateTo(
                        scrollCtrl.position.maxScrollExtent + 100,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                  },
                ),
                HomePageButton(
                    icon: Icons.delete_forever,
                    label: "Delete deck",
                    onPressed: () {
                      if (model.activeDeckI == -1) {
                        showErrorDialog(
                            context, "Failed to delete", "No selected deck");
                        return;
                      }

                      model.deleteDeck(model.activeDeckI);
                    })
              ]),
          const Divider(),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                      controller: scrollCtrl,
                      child: Table(
                        children: const [
                              TableRow(children: [
                                Text("Name",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("Description",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("Cards",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right)
                              ])
                            ] +
                            model.decks
                                .mapIndexed((i, deck) => TableRow(
                                      decoration: BoxDecoration(
                                          color: i == model.activeDeckI
                                              ? Colors.grey.shade700
                                              : Colors.transparent),
                                      children: [
                                        InkWell(
                                          child: Text(deck.name,
                                              style: const TextStyle(
                                                  decoration: TextDecoration
                                                      .underline)),
                                          onTapDown: (_) {
                                            model.activeDeckI = i;
                                          },
                                        ),
                                        Text(deck.description ?? ""),
                                        Text(
                                            deck.cards?.length.toString() ??
                                                "???",
                                            textAlign: TextAlign.right),
                                      ],
                                    ))
                                .toList(growable: false),
                        columnWidths: const {
                          0: FractionColumnWidth(0.30),
                          1: FractionColumnWidth(0.55),
                          2: FractionColumnWidth(0.15)
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                      )))),
        ],
      ),
    );
  }
}

class HomePageButton extends StatelessWidget {
  const HomePageButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  final IconData icon;
  final String label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, minWidth: 300),
        child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => const Color.fromRGBO(255, 255, 255, 0.1))),
          onPressed: onPressed,
          child: Row(children: [
            Icon(icon, color: Colors.white),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child:
                    Text(label, style: const TextStyle(color: Colors.white))),
          ]),
        ));
  }
}
