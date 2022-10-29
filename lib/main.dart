import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

int getRandomWordI(List<Word> words, [int lastVal = -1]) {
  final sum = words.map((e) => e.priority).reduce((val, elem) => val + elem);
  int randomWeight = (Random().nextDouble() * sum).round();

  int i;
  for (i = 0; i < words.length; ++i) {
    randomWeight -= words.elementAt(i).priority;
    if (randomWeight <= 0) {
      break;
    }
  }
  // Retry
  if (i == lastVal) return getRandomWordI(words, lastVal);
  return i;
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
  int _priority = 100;

  void incPriority() {
    ++_priority;
  }

  void decPriority() {
    --_priority;
  }

  int get priority => _priority;

  Word(this.side1, this.side2);
}

enum CardAction {
  normal,
  dontKnow,
  know,
}

class _ListPageState extends State<ListPage> {
  final _cards = [
    Word("Alma", "Apple"),
    Word("Banán", "Banana"),
    Word("Citrom", "Lemon"),
  ];

  final _cardColors = const [
    Color(0xff202020), // Normal
    Color(0xff251b1b), // Dontknow
    Color(0xff222a1e), // Know
  ];

  late int _cardI;
  var _isCardSide1 = true;
  double _cardXDrag = 0.0;
  double _cardYDrag = 0.0;
  int _cardAnimDurMs = 0;
  var _isFlipping = false;

  CardAction _cardAction = CardAction.normal;

  static const _cardW = 250;
  static const _cardH = 500;

  @override
  void initState() {
    super.initState();
    _cardI = getRandomWordI(_cards);
  }

  Matrix4 _calcDragTransfMat(double xDrag, double yDrag) {
    return Matrix4.translationValues(
            _cardW / 2 + xDrag, _cardH.toDouble() + yDrag / 4, 0) *
        Matrix4.rotationZ(xDrag / 3000) *
        Matrix4.translationValues(-_cardW / 2, -_cardH.toDouble(), 0) *
        Matrix4.rotationY(_isFlipping ? pi / 2 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedContainer(
            transformAlignment: Alignment.center,
            duration: Duration(milliseconds: _cardAnimDurMs),
            transform: _calcDragTransfMat(_cardXDrag * 1.2, _cardYDrag),
            width: _cardW.toDouble(),
            height: _cardH.toDouble(),
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: _cardColors[_cardAction.index],
              borderRadius:
                  const BorderRadiusDirectional.all(Radius.circular(20)),
              shadowColor: Colors.red,
              child: GestureDetector(
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white.withAlpha(10),
                    child: Center(
                      child: Text(
                        (_isCardSide1
                            ? _cards.elementAt(_cardI).side1
                            : _cards.elementAt(_cardI).side2),
                        style: const TextStyle(
                            color: Color(0xffaaaaaa), fontSize: 30),
                      ),
                    ),
                    // Note: Use the InkWell's `onTap()` because it seems to get
                    // executed earlier than the GestureDetector's
                    onTap: () {
                      setState(() {
                        _cardAnimDurMs = 200;
                        _isFlipping = true;
                      });

                      Future.delayed(const Duration(milliseconds: 200), () {
                        setState(() {
                          _isCardSide1 = !_isCardSide1;
                          _isFlipping = false;
                        });
                      });
                    }),
                onPanUpdate: (details) {
                  if (_cardXDrag > _cardW / 4) {
                    setState(() {
                      _cardAction = CardAction.know;
                    });
                  } else if (_cardXDrag < -_cardW / 4) {
                    setState(() {
                      _cardAction = CardAction.dontKnow;
                    });
                  } else {
                    setState(() {
                      _cardAction = CardAction.normal;
                    });
                  }
                  setState(() {
                    _cardXDrag += details.delta.dx;
                    _cardYDrag += details.delta.dy;
                    _cardAnimDurMs = 0;
                  });
                },
                onPanEnd: (details) {
                  if (_cardAction == CardAction.know) {
                    _cards.elementAt(_cardI).decPriority();
                    setState(() {
                      _cardI = getRandomWordI(_cards, _cardI);
                      _isCardSide1 = true; // Flip back the card
                    });
                  }
                  /* else if (_cardAction == CardAction.dontKnow) {
                    _cards.elementAt(_cardI).incPriority();
                  }*/

                  setState(() {
                    _cardXDrag = 0;
                    _cardYDrag = 0;
                    // Animate when the card is moving back to center
                    _cardAnimDurMs = 100;
                    _cardAction = CardAction.normal;
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
