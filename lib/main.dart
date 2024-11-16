import 'package:calorie_track/helper/image_classifier_helper.dart';
import 'package:calorie_track/ui/home_page.dart';
import 'package:calorie_track/ui/inference_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
        
        body: HomePage(),
      ),
    );
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

  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid;

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    super.initState();
  }

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  // Process picked image
  Future<void> processImage() async {
    if (imagePath != null) {
      // Read image bytes from file
      final imageData = File(imagePath!).readAsBytesSync();

      // Decode image using package:image/image.dart (https://pub.dev/image)
      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (cameraIsAvailable)
                      TextButton.icon(
                        onPressed: () async {
                          cleanResult();
                          final result = await imagePicker.pickImage(
                            source: ImageSource.camera,
                          );

                          imagePath = result?.path;
                          setState(() {});
                          processImage();
                        },
                        icon: const Icon(
                          Icons.camera,
                          size: 48,
                        ),
                        label: const Text("Camera"),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        cleanResult();
                        final result = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );

                        imagePath = result?.path;

                        processImage();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.photo,
                        size: 48,
                      ),
                      label: const Text("Gallery"),
                    ),
                  ],
                ),
                const Divider(color: Colors.black),
                Column(
                  children: [
                    if (imagePath != null)
                      Image.file(
                        File(imagePath!),
                        width: 200,
                      ),
                    if (image == null)
                      const Text(
                          "Take a photo or choose one from the gallery to "
                          "inference."),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show classification result
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              if (classification != null)
                                ...(classification!.entries.toList()
                                      ..sort(
                                        (a, b) => a.value.compareTo(b.value),
                                      ))
                                    .reversed
                                    .take(10)
                                    .map(
                                      (e) => Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.white,
                                        child: Row(
                                          children: [
                                            Text(e.key),
                                            const Spacer(),
                                            Text(e.value.toStringAsFixed(2))
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
