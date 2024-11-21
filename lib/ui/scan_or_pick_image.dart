import 'dart:io';

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

  @override
  void initState() {
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                        Container(
                            child: IconButton.filled(
                          onPressed: () {},
                          icon: Icon(Icons.camera_enhance_sharp),
                          iconSize: 70,
                        )),
                        Divider(
                          indent: 100,
                          endIndent: 100,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text("Pick food image from gallery?"))
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
