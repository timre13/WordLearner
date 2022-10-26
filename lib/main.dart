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
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xff202020),
            elevation: 1,
          ),
          colorScheme: const ColorScheme.dark(
            secondary: Colors.cyan,
          ),
          scaffoldBackgroundColor: const Color(0xff333333)),
      home: const MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final _pages = List<Widget>.of(const [
    HomePage(),
    ListPage(),
    SettingsPage(),
  ]);
  int _currentPageI = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages[_currentPageI]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int x) {
          setState(() {
            _currentPageI = x;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
        currentIndex: _currentPageI,
      ),
    );
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

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("List"));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings"));
  }
}
