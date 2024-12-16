import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';

import 'package:calorie_track/helper/enums.dart';
import 'package:http/http.dart' as http;
import 'package:calorie_track/helper/image_classifier_helper.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/ui/add_food_page.dart';
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
  final imagePicker = ImagePicker();
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;
  late List<CameraDescription> cameraList;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isLoading = false;

  ImageClassificationHelper? imageClassificationHelper;

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  Future<void> takePicture() async {
    try {
      await _initializeControllerFuture;
      final cameraImage = await _controller.takePicture();
      imagePath = cameraImage.path;
    } catch (e) {
      AppLogger.instance.e("Error at taking picture", error: e);
    }
  }

  // Process picked image
  Future<int> processImage() async {
    // returns -1 if API is inaccessible
    // returns 0 if api returns result
    if (imagePath != null) {
      // Step 2: Create a multipart request using the correct key name expected by the server
      var uri = Uri.parse(
          'https://api.muniza.fyi/infer/'); // Replace with your API URL
      var request =
          http.MultipartRequest('POST', uri); // Assuming the method is POST
      // Step 3: Add the image to the request with the correct key name
      // If the API expects the key 'image', use that here.
      var imageFile = await http.MultipartFile.fromPath(
          'image', imagePath!); // 'image' is the key here
      request.files.add(imageFile);
      request.headers["X-API-KEY"] = "myapp_key";

      // Optional: Add other fields if needed by the API
      // request.fields['key'] = 'value';

      // Step 4: Send the request
      try {
        var streamedResponse = await request.send();

        // Step 5: Check the response status code
        if (streamedResponse.statusCode == 200) {
          // Step 6: Read the response body
          var responseBody = await streamedResponse.stream.bytesToString();

          // Parse the response body to a Map<String, dynamic>
          Map<String, dynamic> responseMap = jsonDecode(responseBody);

          // Extract the predictions list from the response
          var predictions = responseMap['predictions'];

          // Check if predictions is not empty and is a list of lists
          if (predictions != null &&
              predictions is List &&
              predictions.isNotEmpty) {
            // Flatten the predictions (the inner list is a single list of numbers)
            List<double> predictionValues = List<double>.from(predictions[0]);

            classification = await getSortedPredictionMap(predictionValues);
            return 0;
          }
        } else {
          // Log the error and the response body for debugging
          // print('Upload failed. Status Code: ${streamedResponse.statusCode}');
          return -1;
          // print('Response Body: $responseBody');
        }
      } catch (e) {
        // Catch any errors that might occur during the request
        // print('Error during request: $e');
      }

      // // Read image bytes from file
      // final imageData = File(imagePath!).readAsBytesSync();

      // // Decode image using package:image/image.dart (https://pub.dev/image)
      // image = img.decodeImage(imageData);
      // classification = await imageClassificationHelper?.inferenceImage(image!);
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();

    // imageClassificationHelper = ImageClassificationHelper();
    // imageClassificationHelper!.initHelper();
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

    return Stack(
      children: [
        Container(
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
                                cleanResult();
                                setState(() {
                                  _isLoading = true;
                                });
                                await takePicture();
                                var res = await processImage();
                                setState(() {
                                  _isLoading = false;
                                });
                                if (res == -1) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            "Connetion Issue Occurred."),
                                        content: const Text(
                                            "Please try again in a few seconds."),
                                        actions: [
                                          FilledButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              label: const Text("Okay"))
                                        ],
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (context.mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddFoodPage(
                                            classification: classification,
                                            imagePath: imagePath),
                                      ));
                                }
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
                                onPressed: () async {
                                  cleanResult();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final result = await imagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  if (result == null) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }
                                  imagePath = result.path;
                                  var res = await processImage();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (res == -1) {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              "Connetion Issue Occurred."),
                                          content: const Text(
                                              "Please try again in a few seconds."),
                                          actions: [
                                            FilledButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                label: const Text("Okay"))
                                          ],
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddFoodPage(
                                              classification: classification,
                                              imagePath: imagePath),
                                        ));
                                  }
                                },
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
        ),
        Positioned.fill(
            child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      )),
                )
              : const SizedBox(),
        ))
      ],
    );
  }
}
