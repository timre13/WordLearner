import 'package:flutter/material.dart';

import 'home_page.dart';
import 'list_page.dart';
import 'settings_page.dart';

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

class _MainWidgetState extends State<MainWidget> with TickerProviderStateMixin {
  final _pages = const [
    HomePage(),
    ListPage(),
    SettingsPage(),
  ];

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

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _pages.length,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: TabBar(
          tabs: Iterable.generate(_pages.length)
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
            children: _pages,
          ),
        ));
  }
}
