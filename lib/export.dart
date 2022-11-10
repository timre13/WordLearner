import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:word_learner/common.dart';
import 'dart:io';

import 'words.dart';

enum ExportDocTheme {
  light,
  sepia,
  dark;

  PdfColor getFgColor() {
    return const [
      PdfColors.black,
      PdfColor.fromInt(0xff704214),
      PdfColor.fromInt(0xffdddddd)
    ][index];
  }

  PdfColor getBgColor() {
    return const [
      PdfColors.white,
      PdfColor.fromInt(0xffeadbcb),
      PdfColor.fromInt(0xff262626)
    ][index];
  }
}

void exportToPdf(
    BuildContext context, List<Word> words, String path, ExportDocTheme theme) {
  final fgColor = theme.getFgColor();
  final bgColor = theme.getBgColor();
  printing.PdfGoogleFonts.robotoRegular().then((font) {
    var doc = pw.Document();

    final textStyle = pw.TextStyle(font: font, color: fgColor);
    var pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a5,
      theme: pw.ThemeData(defaultTextStyle: textStyle),
      buildBackground: (context) => pw.Container(
        color: bgColor,
      ),
      margin: pw.EdgeInsets.zero,
    );

    doc.addPage(pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) {
          return [
            pw.Container(
                margin:
                    const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: pw.Table(
                    children: words
                        .map((e) => pw.TableRow(
                            children: [pw.Text(e.side1), pw.Text(e.side2)]))
                        .toList()))
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
