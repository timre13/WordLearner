import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:word_learner/main.dart';

import 'common.dart';
import 'export.dart';
import 'words.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.cbs}) : super(key: key);

  final HomePageCallbacks cbs;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    const divider = Divider(
      height: 8,
      thickness: 1,
      indent: 10,
      endIndent: 10,
    );

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
                      words = wordListRemoveDups(loadWordsOrThrow(value));
                    } on FormatException catch (e) {
                      showErrorDialog(
                          context, "Failed to load wordlist", e.message);
                    } on FileSystemException catch (e) {
                      showErrorDialog(
                          context, "Failed to load wordlist", e.message);
                    }
                    if (words.isNotEmpty) {
                      showInfoSnackBar(
                          context, "Loaded ${words.length} word pairs");
                    }
                    widget.cbs.setCardsCb(words);
                  }
                });
              }),
          HomePageButton(
            icon: Icons.file_download,
            label: "Export list...",
            onPressed: () {
              getExternalStorageDirectory().then((path) {
                try {
                  exportToPdf(
                      context,
                      widget.cbs.getCards(),
                      path_pkg.join(path!.path, "words.pdf"),
                      widget.cbs.getExportDocTheme());
                } on FileSystemException catch (e) {
                  if (kDebugMode) {
                    print("Error: ${e.message}");
                  }
                }
              });
            },
          ),
          divider,
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
