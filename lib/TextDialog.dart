import "package:flutter/material.dart";

class TextDialog extends StatefulWidget {
  const TextDialog({super.key});

  @override
  State<TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  var textEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var field = TextField(
        controller: textEditController,
        autofocus: true,
        decoration: const InputDecoration(labelText: "List name"),
        textCapitalization: TextCapitalization.sentences);

    return Dialog(
        shape: const ContinuousRectangleBorder(),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Create List", style: TextStyle(fontSize: 20)),
                Padding(padding: const EdgeInsets.all(10), child: field),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () {
                            var val = textEditController.value.text.trim();
                            if (val.isNotEmpty) {
                              Navigator.pop(context, val);
                            }
                          },
                          child:
                              const Text("OK", style: TextStyle(fontSize: 16))),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(fontSize: 16))),
                    ])
              ],
            )));
  }

  @override
  void dispose() {
    super.dispose();
    textEditController.dispose();
  }
}
