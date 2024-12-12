import 'package:calorie_track/ui/home_page.dart';
import 'package:calorie_track/ui/scan_or_pick_image.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  void handleBottomNavigation(int value) {}

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
      onTap: (int index) {
        setState(() {
          pageIndex = index;
        });
      },
      currentIndex: pageIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.switch_access_shortcut_add,
              size: 30,
            ),
            label: "Inference",
            activeIcon: Icon(
              Icons.switch_access_shortcut_add,
              size: 30,
            )),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      ],
    );
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[600]!)),
      color: Colors.blue[400],
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          bottomNavigationBar: bottomNavigationBar,
          key: scaffoldKey,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _getPageForIndex(pageIndex),
          ),
        ),
      ),
    );
  }
}

Widget _getPageForIndex(int pageIndex) {
  switch (pageIndex) {
    case 0:
      return const HomePage(key: ValueKey(0));
    case 1:
      return const ScanOrPickImagePage(key: ValueKey(1));
    default:
      return const HomePage(key: ValueKey(-1));
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void showSuccessSnackBar(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text(
          "The caloric detail of the food has been added!",
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: const StadiumBorder(),
        backgroundColor: Colors.green[800],
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(30),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Placeholder(),
    );
  }
}
