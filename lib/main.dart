import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_learner/database.dart';
import 'package:word_learner/settings.dart';
import 'package:word_learner/state.dart';

import 'card_page.dart';
import 'home_page.dart';
import 'list_page.dart';
import 'settings_page.dart';

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
      home: const ExcludeFocus(child: WrapperWidget()),
    );
  }
}

class WrapperWidget extends StatefulWidget {
  const WrapperWidget({super.key});

  @override
  State<WrapperWidget> createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  late Future<Database> _dbFuture;
  late Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();

    _dbFuture = Database.create();

    _prefsFuture = () async {
      final val = await SharedPreferences.getInstance();
      FlutterNativeSplash.remove();
      return val;
    }();
  }

  @override
  Widget build(BuildContext context) {
    double topPaddingNeeded =
        View.of(context).padding.top / View.of(context).devicePixelRatio;

    return FutureBuilder(
        future: Future.wait([_dbFuture, _prefsFuture]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Material(
                child: Center(child: Text("Error: ${snapshot.error}")));
          }

          if (!snapshot.hasData) {
            return Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                    child: SizedBox.fromSize(
                        size: const Size.square(300),
                        child: CircularProgressIndicator(
                            backgroundColor: Theme.of(context)
                                .tabBarTheme
                                .unselectedLabelColor,
                            color: Theme.of(context).colorScheme.secondary,
                            strokeWidth: 8))));
          }

          return MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) =>
                    MainModel(db: snapshot.data![0] as Database)),
            ChangeNotifierProvider(
                create: (context) => SettingsModel(
                    prefs: snapshot.data![1] as SharedPreferences,
                    topPaddingNeeded: topPaddingNeeded)),
          ], child: const MainWidget());
        });
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  final _pageIcons = const [
    Icons.home,
    Icons.crop_portrait_rounded,
    Icons.list,
    Icons.settings,
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: _pageIcons.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));

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
    final settings = Provider.of<SettingsModel>(context);
    final showLargeTabs = MediaQuery.of(context).size.width > 600;
    return Scaffold(
        bottomNavigationBar: TabBar(
          isScrollable: showLargeTabs ? true : false,
          tabAlignment: showLargeTabs ? TabAlignment.center : TabAlignment.fill,
          labelPadding: showLargeTabs
              ? const EdgeInsets.symmetric(horizontal: 20)
              : EdgeInsets.zero,
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
                  padding: EdgeInsets.only(top: settings.topPadding),
                  child: const HomePage()),
              const CardPage(),
              const ListPage(),
              Padding(
                  padding: EdgeInsets.only(top: settings.topPadding),
                  child: const SettingsPage()),
            ],
          ),
        ));
  }
}
