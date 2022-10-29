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

  var _isCardSide1 = true;
  double _cardXDrag = 0.0;
  double _cardYDrag = 0.0;
  int _cardAnimDurMs = 0;

  static const _cardW = 250;
  static const _cardH = 500;

  Matrix4 _calcDragTransfMat(double xDrag, double yDrag) {
    return Matrix4.translationValues(
            _cardW / 2 + xDrag, _cardH.toDouble() + yDrag / 4, 0) *
        Matrix4.rotationZ(xDrag / 3000) *
        Matrix4.translationValues(-_cardW / 2, -_cardH.toDouble(), 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedContainer(
            duration: Duration(milliseconds: _cardAnimDurMs),
            transform: _calcDragTransfMat(_cardXDrag * 1.2, _cardYDrag),
            width: _cardW.toDouble(),
            height: _cardH.toDouble(),
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: const Color(0xff202020),
              borderRadius:
                  const BorderRadiusDirectional.all(Radius.circular(20)),
              child: GestureDetector(
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white.withAlpha(10),
                    child: Center(
                      child: Text(
                        (_isCardSide1
                                ? _cards.first.side1
                                : _cards.first.side2) +
                            "\n" +
                            _cardXDrag.toString(),
                        style: const TextStyle(
                            color: Color(0xffaaaaaa), fontSize: 30),
                      ),
                    ),
                    // Note: Use the InkWell's `onTap()` because it seems to get
                    // executed earlier than the GestureDetector's
                    onTap: () {
                      setState(() {
                        _isCardSide1 = !_isCardSide1;
                      });
                    }),
                onPanUpdate: (details) {
                  setState(() {
                    _cardXDrag += details.delta.dx;
                    _cardYDrag += details.delta.dy;
                    _cardAnimDurMs = 0;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _cardXDrag = 0;
                    _cardYDrag = 0;
                    // Animate when the card is moving back to center
                    _cardAnimDurMs = 100;
                  });
                },
              ),
            )));
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
