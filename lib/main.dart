import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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

  HomePageCallbacks({required this.setCardsCb, required this.getCards});
}

class ListPageCallbacks {
  final void Function(int index) incCardPriorityCb;
  final void Function(int index) decCardPriorityCb;
  final OrderMode Function() getOrderMode;

  ListPageCallbacks(
      {required this.incCardPriorityCb,
      required this.decCardPriorityCb,
      required this.getOrderMode});
}

class SettingsPageCallbacks {
  final OrderMode Function() getOrderMode;
  final void Function(OrderMode mode) setOrderMode;
  final bool Function() getHideNotifAndNavBar;
  final void Function(bool hide) setHideNotifAndNavBar;

  SettingsPageCallbacks(
      {required this.getOrderMode,
      required this.setOrderMode,
      required this.getHideNotifAndNavBar,
      required this.setHideNotifAndNavBar});
}

enum SettingKeys {
  orderMode,
  hideNotifAndNavBar,
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  //final _pageNames = const [
  //  "Home",
  //  "List",
  //  "Settings",
  //];

  final _pageIcons = const [
    Icons.home,
    Icons.list,
    Icons.settings,
  ];

  late SharedPreferences _prefs;
  List<Word> _cards = [];

  late HomePageCallbacks _homePageCallbacks;
  late ListPageCallbacks _listPageCallbacks;
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
    );

    _listPageCallbacks = ListPageCallbacks(
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
    );

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
                    //text: _pageNames[i],
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
              ListPage(cards: _cards, cbs: _listPageCallbacks),
              Padding(
                  padding: EdgeInsets.only(top: _topPadding),
                  child: SettingsPage(cbs: _settingsPageCallbacks)),
            ],
          ),
        ));
  }
}
