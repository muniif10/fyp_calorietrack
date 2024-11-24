import 'dart:io';
import 'package:calorie_track/helper/image_classifier_helper.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class InferencePage extends StatefulWidget {
  const InferencePage({super.key});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
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
        child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: primaryBackgroundGradient),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                  const Divider(),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                            colors: secondaryBackgroundGradient)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
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
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget card() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: AspectRatio(
        aspectRatio: 3 / 1,
        child: Image.network(
          "https://github.com/michael-gh1/Addons-And-Tools-For-Blender-miHoYo-Shaders/raw/main/assets/gi_hsr_pgr_banner.jpg",
        ),
      ),
    );
  }
}
