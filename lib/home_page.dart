import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'words.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.setCardsCb}) : super(key: key);

  final void Function(List<Word> newCards) setCardsCb;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showErrorDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            icon: const Icon(Icons.error),
            iconColor: Colors.red,
          );
        });
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            icon: const Icon(Icons.info),
            iconColor: Colors.blue,
          );
        });
  }

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
                    List<Word> words = [];
                    try {
                      words = loadWordsOrThrow(value);
                    } on FormatException catch (e) {
                      _showErrorDialog("Failed to load wordlist", e.message);
                    } on FileSystemException catch (e) {
                      _showErrorDialog("Failed to load wordlist", e.message);
                    }
                    if (words.isNotEmpty) {
                      _showInfoDialog("Loaded wordlist",
                          "Loaded ${words.length} word pairs");
                    }
                    widget.setCardsCb(words);
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
                WidgetsFlutterBinding.ensureInitialized();
                PackageInfo.fromPlatform().then((pkgInfo) {
                  showAboutDialog(
                      context: context,
                      applicationName: pkgInfo.appName,
                      applicationVersion: "${pkgInfo.packageName}"
                          "\n\nVersion: ${pkgInfo.version}"
                          "\nBuild number: ${pkgInfo.buildNumber}");
                });
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
