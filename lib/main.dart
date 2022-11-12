import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_page.dart';
import 'export.dart';
import 'home_page.dart';
import 'list_page.dart';
import 'settings_page.dart';
import 'words.dart';

void main() {
  // Don't close splash screen yet
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Word Learner",
      theme: ThemeData(
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey,
        )),
        colorScheme: const ColorScheme.dark(
          secondary: Colors.cyan,
        ),
        scaffoldBackgroundColor: const Color(0xff333333),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.cyan,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(),
        ),
      ),
      home: const MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
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

class HomePageCallbacks {
  final void Function(List<Word> newCards) setCardsCb;
  final List<Word> Function() getCards;
  final ExportDocTheme Function() getExportDocTheme;

  HomePageCallbacks({
    required this.setCardsCb,
    required this.getCards,
    required this.getExportDocTheme,
  });
}

class CardPageCallbacks {
  final void Function(int index) incCardPriorityCb;
  final void Function(int index) decCardPriorityCb;
  final OrderMode Function() getOrderMode;

  CardPageCallbacks({
    required this.incCardPriorityCb,
    required this.decCardPriorityCb,
    required this.getOrderMode,
  });
}

class SettingsPageCallbacks {
  final OrderMode Function() getOrderMode;
  final void Function(OrderMode mode) setOrderMode;

  final bool Function() getHideNotifAndNavBar;
  final void Function(bool hide) setHideNotifAndNavBar;

  final ExportDocTheme Function() getExportDocTheme;
  final Function(ExportDocTheme theme) setExportDocTheme;

  SettingsPageCallbacks({
    required this.getOrderMode,
    required this.setOrderMode,
    required this.getHideNotifAndNavBar,
    required this.setHideNotifAndNavBar,
    required this.getExportDocTheme,
    required this.setExportDocTheme,
  });
}

enum SettingKeys {
  orderMode,
  hideNotifAndNavBar,
  exportDocTheme,
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  final _pageIcons = const [
    Icons.home,
    Icons.crop_portrait_rounded,
    Icons.list,
    Icons.settings,
  ];

  late SharedPreferences _prefs;
  List<Word> _cards = [];

  late HomePageCallbacks _homePageCallbacks;
  late CardPageCallbacks _cardPageCallbacks;
  late SettingsPageCallbacks _settingsPageCallbacks;

  late TabController _tabController;

  double _topPadding = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _pageIcons.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));

    OrderMode getOrderMode() =>
        OrderMode.values[(_prefs.getInt(SettingKeys.orderMode.name) ?? 0)];

    bool getHideNotifAndNavBar() =>
        (_prefs.getBool(SettingKeys.hideNotifAndNavBar.name) ?? false);

    ExportDocTheme getExportDocTheme() => ExportDocTheme
        .values[(_prefs.getInt(SettingKeys.exportDocTheme.name) ?? 0)];

    void updateNotifAndNavBar() {
      if (getHideNotifAndNavBar()) {
        setState(() {
          // If we hide the notification bar, the notch
          // will cover some of the UI. We use padding on the home and settings
          // pages. Here we get the necessary padding before hiding the
          // notification bar.
          _topPadding = WidgetsBinding.instance.window.padding.top /
              WidgetsBinding.instance.window.devicePixelRatio;
        });
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        setState(() {
          _topPadding = 0;
        });
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
      }
    }

    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      FlutterNativeSplash.remove();
      updateNotifAndNavBar();
    });

    _homePageCallbacks = HomePageCallbacks(
      //
      setCardsCb: (newCards) {
        setState(() {
          _cards = newCards;
        });
      },
      getCards: () => _cards,
      getExportDocTheme: getExportDocTheme,
    );

    _cardPageCallbacks = CardPageCallbacks(
      //
      incCardPriorityCb: (index) {
        setState(() {
          _cards[index].incPriority();
        });
      },
      decCardPriorityCb: (index) {
        setState(() {
          _cards[index].decPriority();
        });
      },
      getOrderMode: getOrderMode,
    );

    _settingsPageCallbacks = SettingsPageCallbacks(
        //
        getOrderMode: getOrderMode,
        setOrderMode: (mode) {
          setState(() {
            _prefs.setInt(SettingKeys.orderMode.name, mode.index);
          });
        },
        getHideNotifAndNavBar: getHideNotifAndNavBar,
        setHideNotifAndNavBar: (hide) {
          setState(() {
            _prefs.setBool(SettingKeys.hideNotifAndNavBar.name, hide);
            updateNotifAndNavBar();
          });
        },
        getExportDocTheme: getExportDocTheme,
        setExportDocTheme: (theme) {
          setState(() {
            _prefs.setInt(SettingKeys.exportDocTheme.name, theme.index);
          });
        });

    // This is called when the navbar becomes visible.
    // When the triggering condition no longer applies, the settings won't be
    // restored, so we restore them manually.
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) {
      // Go back to fullscreen
      // Note: from flutter docs: "the UI visibility cannot be changed until 1 second
      //       after the keyboard is closed to prevent malware locking users
      //       from navigation buttons"
      return Future.delayed(const Duration(seconds: 1, milliseconds: 10), () {
        SystemChrome.restoreSystemUIOverlays();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: TabBar(
          tabs: Iterable.generate(_pageIcons.length)
              .toList()
              .map((i) => Tab(
                    icon: Icon(_pageIcons[i], size: 40),
                  ))
              .toList(),
          controller: _tabController,
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                  padding: EdgeInsets.only(top: _topPadding),
                  child: HomePage(cbs: _homePageCallbacks)),
              CardPage(cards: _cards, cbs: _cardPageCallbacks),
              Padding(
                  padding: EdgeInsets.only(top: _topPadding),
                  child: ListPage(cards: _cards)),
              Padding(
                  padding: EdgeInsets.only(top: _topPadding),
                  child: SettingsPage(cbs: _settingsPageCallbacks)),
            ],
          ),
        ));
  }
}
