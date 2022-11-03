import 'package:flutter/material.dart';
import 'package:word_learner/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.cbs}) : super(key: key);

  final SettingsPageCallbacks cbs;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  final _textFieldVal = "Default Value";

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var fieldWidget =
        TextField(controller: TextEditingController(text: _textFieldVal));

    // TODO: Option to hide notification bar

    return Center(
      child: Column(
        children: [
          const Text(
            "Settings",
            textScaleFactor: 2,
          ),
          fieldWidget,
        ],
      ),
    );
  }
}
