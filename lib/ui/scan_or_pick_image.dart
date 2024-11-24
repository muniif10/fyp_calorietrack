import 'dart:io';

import 'package:calorie_track/helper/image_classifier_helper.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ScanOrPickImagePage extends StatefulWidget {
  const ScanOrPickImagePage({super.key});

  @override
  State<ScanOrPickImagePage> createState() => _ScanOrPickImagePageState();
}

class _ScanOrPickImagePageState extends State<ScanOrPickImagePage> {
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;
  late List<CameraDescription> cameraList;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  ImageClassificationHelper? imageClassificationHelper;

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  void takePicture() async {
    try {
      await _initializeControllerFuture;
      final cameraImage = await _controller.takePicture();
      imagePath = cameraImage.path;
    } catch (e) {
      AppLogger.instance.e("Error at taking picture", error: e);
    }
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
  void initState() {
    super.initState();

    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    super.initState();

    // Initialize the camera controller if cameras are available
    if (cameraIsAvailable) {
      _initializeControllerFuture = _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Get the list of available cameras
      cameraList = await availableCameras();

      // Use the first available camera
      final cameraUsed = cameraList.first;

      // Create the camera controller
      _controller = CameraController(
        cameraUsed,
        ResolutionPreset.medium,
      );

      // Initialize the controller
      await _controller.initialize();
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the camera controller if initialized
    if (cameraIsAvailable) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraIsAvailable) {
      return const Center(child: Text("Camera not available on this device."));
    }

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: primaryBackgroundGradient)),
      child: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller.value.isInitialized) {
            // Camera initialized, show the preview
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Camera Preview with border radius
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CameraPreview(_controller),
                        ),
                      ),

                      // Positioned widget for centered text at the top
                      Opacity(
                        opacity: 0.7,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Align(
                            alignment: Alignment.topCenter,
                            // Align to the right of the Stack
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    colors: secondaryBackgroundGradient,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Align the food within camera view.",
                                    textAlign: TextAlign
                                        .center, // Center text inside the container
                                    style: TextStyle(
                                      color: primaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () async {
                            takePicture();
                            await processImage();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFoodPage(
                                      classification: classification,
                                      imagePath: imagePath),
                                ));
                          },
                          icon: const Icon(Icons.camera_enhance_sharp),
                          iconSize: 40,
                          padding: const EdgeInsets.all(20),
                        ),
                        const Divider(
                          indent: 100,
                          endIndent: 100,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: const Text("Choose image from gallery"))
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            // Loading state
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

  List<MapEntry<String, double>> sortClassification(
      Map<String, double>? classification) {
    if (classification == null) {
      return []; // Return an empty list if the map is null
    }

    // Sort the map by values in descending order and return the sorted list
    var sortedList = classification.entries.toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Compare the values in descending order

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedListClassification =
        sortClassification(classification);
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: [
            // Take 3 of the likely food
            ...sortedListClassification.take(3).map((entry) {
              return Text("${entry.key} ${entry.value}");
            })
          ],
        ),
      ),
    );
  }
}
