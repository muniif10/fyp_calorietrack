import 'package:calorie_track/ui/history_page.dart';
import 'package:calorie_track/ui/home_page.dart';
import 'package:calorie_track/ui/login_page.dart';
import 'package:calorie_track/ui/scan_or_pick_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      setState(() {
        _isLoggedIn = user != null; // Update state based on user authentication
      });
    });
  }

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
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      ],
    );
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[600]!)),
      color: Colors.blue[400],
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: SafeArea(
          child: Builder(builder: (context) {
            if (!_isLoggedIn) {
              return const LoginPage();
            }
            return Scaffold(
              bottomNavigationBar: bottomNavigationBar,
              key: scaffoldKey,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _getPageForIndex(pageIndex),
              ),
            );
          }),
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
      return const HistoryPage(key: ValueKey(2));
  }
}
