import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learner/common.dart';
import 'package:word_learner/export.dart';
import 'package:word_learner/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.cbs});

  final SettingsPageCallbacks cbs;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // TODO: Option to hide notification bar

    final rows = [
      Row(
        children: [
          const Text("Ordering: "),
          DropdownButton(
            style: const TextStyle(fontSize: 14),
            iconEnabledColor: Colors.cyan,
            underline: Container(height: 2, color: Colors.cyan.withAlpha(150)),
            items: OrderMode.values
                .map((orderMode) => DropdownMenuItem(
                    value: orderMode, child: Text(orderMode.toString())))
                .toList(),
            onChanged: (value) {
              setState(() {
                widget.cbs.setOrderMode(value!);
              });
            },
            value: widget.cbs.getOrderMode(),
          )
        ],
      ),
      Row(
        children: [
          const Text("Hide system UI: "),
          CupertinoSwitch(
              value: widget.cbs.getHideNotifAndNavBar(),
              onChanged: (value) {
                widget.cbs.setHideNotifAndNavBar(value);
              },
              trackColor: Colors.blueGrey.shade800,
              activeColor: const Color(0xFF4CAF90))
        ],
      ),
      Row(
        children: [
          const Text("Export theme: "),
          DropdownButton(
            style: const TextStyle(fontSize: 14),
            iconEnabledColor: Colors.cyan,
            underline: Container(height: 2, color: Colors.cyan.withAlpha(150)),
            items: ExportDocTheme.values
                .map((theme) => DropdownMenuItem(
                    value: theme, child: Text(theme.name.capitalize())))
                .toList(),
            onChanged: (value) {
              setState(() {
                widget.cbs.setExportDocTheme(value!);
              });
            },
            value: widget.cbs.getExportDocTheme(),
          )
        ],
      ),
    ];

    return Center(
      child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              const Text(
                "Settings",
                textScaler: TextScaler.linear(2),
              ),
              ...rows,
              // TODO: Link to github repo and profile
            ],
          )),
    );
  }
}
