import "package:flutter/material.dart";

class TextDialog extends StatefulWidget {
  const TextDialog({super.key, required this.title, required this.fieldText});

  final String title;
  final String fieldText;

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
        decoration: InputDecoration(labelText: widget.fieldText),
        textCapitalization: TextCapitalization.sentences);

    return SimpleDialog(shape: const ContinuousRectangleBorder(), children: [
      Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 20)),
              Padding(padding: const EdgeInsets.all(10), child: field),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                    onPressed: () {
                      var val = textEditController.value.text.trim();
                      if (val.isNotEmpty) {
                        Navigator.pop(context, val);
                      }
                    },
                    child: const Text("OK", style: TextStyle(fontSize: 16))),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text("Cancel", style: TextStyle(fontSize: 16))),
              ])
            ],
          ))
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    textEditController.dispose();
  }
}
