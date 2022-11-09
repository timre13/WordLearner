import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:word_learner/common.dart';
import 'dart:io';

import 'words.dart';

void exportToPdf(BuildContext context, List<Word> words, String path) {
  var doc = pw.Document();
  printing.PdfGoogleFonts.robotoRegular().then((font) {
    final textStyle = pw.TextStyle(font: font);
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        build: (context) {
          return [
            pw.Table(
                children: words
                    .map((e) => pw.TableRow(children: [
                          pw.Text(e.side1, style: textStyle),
                          pw.Text(e.side2, style: textStyle)
                        ]))
                    .toList())
          ];
        }));
    doc.save().then((content) =>
        File(path).writeAsBytes(content, flush: true).then((_) {
          if (kDebugMode) {
            print("Wrote PDF file to $path");
          }
          showInfoDialog(context, "Exported wordlist", "Wrote PDF to '$path'");
        }));
  });
}
