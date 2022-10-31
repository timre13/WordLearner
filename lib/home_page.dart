import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'words.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.setCardsCb}) : super(key: key);

  final void Function(List<Word> newCards) setCardsCb;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Word Learner", textScaleFactor: 2)),
          HomePageButton(
              icon: Icons.file_open,
              label: "Open list...",
              onPressed: () {
                const params = OpenFileDialogParams(
                    dialogType: OpenFileDialogType.document);
                FlutterFileDialog.pickFile(params: params).then((value) {
                  if (value != null) {
                    widget.setCardsCb(loadWords(value));
                  }
                });
              }),
          HomePageButton(
              icon: Icons.file_download,
              label: "Export list...",
              onPressed: () {}),
          HomePageButton(
              icon: Icons.info,
              label: "About WordLearner...",
              onPressed: () {
              }),
        ],
      ),
    );
  }
}

class HomePageButton extends StatelessWidget {
  const HomePageButton(
      {Key? key,
      required this.icon,
      required this.label,
      required this.onPressed})
      : super(key: key);

  final IconData icon;
  final String label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(children: [
        Icon(icon),
        Padding(padding: const EdgeInsets.only(left: 10), child: Text(label)),
      ]),
    );
  }
}
