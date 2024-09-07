import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingKeys {
  orderMode,
  hideNotifAndNavBar,
  exportDocTheme,
}

enum OrderMode {
  randomPrio,
  random,
  original;

  @override
  String toString() {
    return [
      "Random with priority",
      "Random",
      "Original",
    ][index];
  }
}

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

class SettingsModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  final double _topPaddingNeeded;
  double _topPadding = 0;

  SettingsModel(
      {required SharedPreferences prefs, required double topPaddingNeeded})
      : _prefs = prefs,
        _topPaddingNeeded = topPaddingNeeded {
    _updateNotifAndNavBar();
  }

  // ---------- Getters ----------

  OrderMode get orderMode =>
      OrderMode.values[(_prefs.getInt(SettingKeys.orderMode.name) ?? 0)];

  bool get hideNotifAndNavBar =>
      (_prefs.getBool(SettingKeys.hideNotifAndNavBar.name) ?? false);

  ExportDocTheme get exportDocTheme => ExportDocTheme
      .values[(_prefs.getInt(SettingKeys.exportDocTheme.name) ?? 0)];

  double get topPadding => _topPadding;

  // ---------- Setters ----------

  set orderMode(OrderMode value) {
    _prefs.setInt(SettingKeys.orderMode.name, value.index);
    notifyListeners();
  }

  set hideNotifAndNavBar(bool value) {
    _prefs.setBool(SettingKeys.hideNotifAndNavBar.name, value);
    _updateNotifAndNavBar();
    notifyListeners();
  }

  set exportDocTheme(ExportDocTheme value) {
    _prefs.setInt(SettingKeys.exportDocTheme.name, value.index);
    notifyListeners();
  }

  void _updateNotifAndNavBar() {
    if (hideNotifAndNavBar) {
      // If we hide the notification bar, the notch
      // will cover some of the UI. We use padding on the home and settings
      // pages. Here we get the necessary padding before hiding the
      // notification bar.
      _topPadding = _topPaddingNeeded;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _topPadding = 0;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  }
}
