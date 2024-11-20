import 'package:calorie_track/helper/image_classifier_helper.dart';
import 'package:calorie_track/ui/home_page.dart';
import 'package:calorie_track/ui/inference_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../ui/const.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
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
          // drawer: Drawer(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       ListTile(onTap: () => {},
          //       minTileHeight: 88,
          //         title: Text("Home"),
          //         leading: Icon(Icons.home),
          //       ),
          //       ListTile(onTap: () => {},
          //       minTileHeight: 88,
          //         title: Text("Statistics"),
          //         leading: Icon(Icons.auto_graph),
          //       ),

          //       ListTile(onTap: () => {},
          //       minTileHeight: 88,
          //         title: Text("Settings"),
          //         leading: Icon(Icons.settings),
          //       ),
          //     ],
          //   ),
          // ),
          // appBar: AppBar(
          //   elevation: 0,
          //   backgroundColor: Colors.transparent,
          //   centerTitle: true,
          //   leading: IconButton(
          //       onPressed: () {
          //         scaffoldKey.currentState?.openDrawer();
          //       },
          //       icon: const Icon(Icons.menu)),
          //   actions: [
          //     IconButton(
          //       onPressed: () {},
          //       icon: Icon(Icons.person),
          //     )
          //   ],
          // ),

          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
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
      return HomePage(key: ValueKey(0));
    case 1:
      return inference_page(key: ValueKey(1));
    default:
      return HomePage(key: ValueKey(-1));
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
        shape: StadiumBorder(),
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(30),
        duration: Duration(seconds: 5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Placeholder(),
    );
  }
}
