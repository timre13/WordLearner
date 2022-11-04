import 'package:flutter/material.dart';

import 'home_page.dart';
import 'list_page.dart';
import 'settings_page.dart';
import 'words.dart';

void main() {
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

  HomePageCallbacks({required this.setCardsCb});
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

  SettingsPageCallbacks(
      {required this.getOrderMode, required this.setOrderMode});
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

  List<Word> _cards = [];
  OrderMode _orderMode = OrderMode.randomPrio;

  late HomePageCallbacks _homePageCallbacks;
  late ListPageCallbacks _listPageCallbacks;
  late SettingsPageCallbacks _settingsPageCallbacks;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _pageIcons.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));

    _homePageCallbacks = HomePageCallbacks(
      //
      setCardsCb: (newCards) {
        setState(() {
          _cards = newCards;
        });
      },
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
      getOrderMode: () => _orderMode,
    );

    _settingsPageCallbacks = SettingsPageCallbacks(
      //
      setOrderMode: (mode) {
        setState(() {
          _orderMode = mode;
        });
      },
      getOrderMode: () => _orderMode,
    );
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
              HomePage(cbs: _homePageCallbacks),
              ListPage(cards: _cards, cbs: _listPageCallbacks),
              SettingsPage(cbs: _settingsPageCallbacks),
            ],
          ),
        ));
  }
}
