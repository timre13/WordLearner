import 'package:flutter/material.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home"));
  }
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class Word {
  String side1;
  String side2;

  Word(this.side1, this.side2);
}

class _ListPageState extends State<ListPage> {
  final _cards = {
    Word("Alma", "Apple"),
    Word("Banán", "Banana"),
    Word("Citrom", "Lemon"),
  };

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
          color: const Color(0xff202020),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ]),
      width: 250,
      height: 500,
      child: Center(
          child: Text(
        _cards.first.side1,
        style: const TextStyle(color: Color(0xffaaaaaa), fontSize: 30),
      )),
    ));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  final _textFieldVal = "Default Value";

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var fieldWidget =
        TextField(controller: TextEditingController(text: _textFieldVal));

    return Center(
      child: Column(
        children: [
          const Text("Settings"),
          fieldWidget,
        ],
      ),
    );
  }
}
