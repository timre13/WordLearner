import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
