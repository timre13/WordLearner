import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String title, String message) {
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

void showInfoDialog(BuildContext context, String title, String message) {
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

void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.white)),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.blueGrey.shade900,
    behavior: SnackBarBehavior.floating,
  ));
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
