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
      )
    ];

    return Center(
      child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              const Text(
                "Settings",
                textScaleFactor: 2,
              ),
              ...rows
            ],
          )),
    );
  }
}
