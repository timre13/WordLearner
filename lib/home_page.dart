import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import "package:word_learner/TextDialog.dart";
import 'package:word_learner/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cbs});

  final HomePageCallbacks cbs;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final scrollCtrl = ScrollController();

    return Center(
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Word Learner", textScaler: TextScaler.linear(2))),
          HomePageButton(
            icon: Icons.file_open,
            label: "Create list...",
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const TextDialog()).then((listName) {
              if (listName == null) {
                return;
              }
              setState(() {
                widget.cbs.createDeck(listName);
              });
              scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent + 100,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
            }),
          ),
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
                            widget.cbs
                                .getDecks()
                                .mapIndexed((i, deck) => TableRow(
                                      decoration: BoxDecoration(
                                          color:
                                              i == widget.cbs.getActiveDeckI()
                                                  ? Colors.grey.shade700
                                                  : Colors.transparent),
                                      children: [
                                        InkWell(
                                          child: Text(deck.name,
                                              style: const TextStyle(
                                                  decoration: TextDecoration
                                                      .underline)),
                                          onTapDown: (_) {
                                            widget.cbs.setActiveDeckI(i);
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
    return OutlinedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
              (states) => const Color.fromRGBO(255, 255, 255, 0.1))),
      onPressed: onPressed,
      child: Row(children: [
        Icon(icon, color: Colors.white),
        Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(label, style: const TextStyle(color: Colors.white))),
      ]),
    );
  }
}
