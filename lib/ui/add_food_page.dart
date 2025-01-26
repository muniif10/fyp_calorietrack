import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:calorie_track/ui/prediction_modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // Import the image package

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

void showSuccessSnackBar(BuildContext ctx, String msg, int type) {
  ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.fixed,
      showCloseIcon: true,
      // shape: const StadiumBorder(),
      backgroundColor: type == 1 ? Colors.green[800] : Colors.grey[700],
      padding: const EdgeInsets.all(15),
      // margin: const EdgeInsets.all(30),
      duration: const Duration(
          seconds:
              4), // Set a longer duration to let the fade-out effect happen
    ),
  );
}

class _AddFoodPageState extends State<AddFoodPage> {
  final List<String> items = [
    "1. Select the thumb which is used for approximation",
    "2. Select multiple part of the food",
    "3. Press confirm to perform the calorie prediction or clear selection to reselect everything",
    "Notice: Calorie estimation may not 100% accurate and may be different from the actual calorie."
    // Add more items as needed
  ];
  List<Offset> coordinates = [];
  double portionSliderValue = 1;
  double predictedCalorie = 0;
  bool usePredictedCalories = false;

  double totalCalorie = 0;

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

  /// Returns 1 if user selected appropriate amount of points in the dialogue, else return -1
  Future<int> _showPointSelector(BuildContext context, String imagePath) async {
    final selectedPoints = await showDialog<List<Offset>>(
      context: context,
      builder: (context) => ImagePageWidget(
        imagePath: imagePath,
      ),
    );
    if (selectedPoints != null) {
      coordinates = selectedPoints;
      return 1;
    }
    return -1;
  }


void addMeal(MapEntry<String, double> entry, int portion, double calories, String imagePath) async {
  FirestoreHelper db = FirestoreHelper();

  // Read the image file
  File imageFile = File(imagePath);
  List<int> imageBytes = await imageFile.readAsBytes();

  // Convert List<int> to Uint8List
  Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);

  // Decode the image to manipulate it
  img.Image? originalImage = img.decodeImage(uint8ImageBytes);

  if (originalImage != null) {
    // Resize the image to a smaller dimension (e.g., 300x300) and compress to lower quality
    // img.Image resizedImage = img.copyResize(originalImage, width: 300, height: 300);

    // Convert the resized image back to bytes with a lower quality
    List<int> compressedBytes = img.encodeJpg(originalImage, quality: 30); // Lower quality (0-100)

    // Encode the compressed bytes to base64
    String base64Image = base64Encode(compressedBytes);

    // Add the meal with the compressed image
    db.addMeal(Meal(
      foodName: entry.key,
      calorieInput: calories,
      portion: portion,
      insertionDate: DateTime.now().toIso8601String(),
      imageBase64: base64Image,
    ));
  } else {
    // Handle image decoding failure
    // print("Failed to decode the image.");
    AppLogger.instance.e("Failed to decode image.");
  }
}

  Future<int> performPortionPrediction(
      String imagePath, Function failCallback) async {
    var uri = Uri.parse('https://api.muniza.fyi/predict');
    var request = http.MultipartRequest('POST', uri);
    var imageFile = await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(imageFile);
    List<List<double>> foodPoints = [];
    for (int i = 1; i < coordinates.length; i++) {
      foodPoints.add([coordinates[i].dx, coordinates[i].dy]);
    }
    request.headers["X-API-KEY"] = "myapp_key";
    request.fields['points'] = jsonEncode({
      "thumb_point": [coordinates[0].dx, coordinates[0].dy],
      "food_point": foodPoints,
    });

    try {
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        var responseBody = await streamedResponse.stream.bytesToString();
        Map<String, dynamic> responseMap = jsonDecode(responseBody);
        double volPredDouble = responseMap['food_volume_cm3'];
        int foodVolPrediction = volPredDouble.toInt();
        return foodVolPrediction;
      } else {
        failCallback();
      }
    } catch (e) {
      AppLogger.instance.e('Error: Volume prediction error', error: e);
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedListClassification =
        sortClassification(widget.classification);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Meal"),
      ),
      body: SafeArea(
        child: PageView(
          children: sortedListClassification.map((entry) {
            double initialCalories =
                double.parse(labelAttributes[entry.key]?["calories"] ?? "0");
            double totalCalorie = initialCalories * portionSliderValue;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(widget.imagePath!),
                          width: 200,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient:
                              LinearGradient(colors: primaryBackgroundGradient),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                getHumanReadableName(entry.key),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryText),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  labelAttributes[entry.key]?["description"] ??
                                      "",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Portion Size"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Show the first dialog to check before proceeding
                          var isDialogConfirmed = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Predicting Meal Calorie"),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize
                                    .min, // This ensures the column takes only the space needed by its children
                                children: items.map((e) => Text(e)).toList(),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        false); // Close dialog with 'false' to indicate not ready
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        true); // Close dialog with 'true' to indicate ready
                                  },
                                  child: const Text("Proceed"),
                                ),
                              ],
                            ),
                          );

                          // Check if the first dialog was confirmed (i.e., user pressed 'Proceed')
                          if (context.mounted) {
                            if (isDialogConfirmed == true) {
                              int stat = await _showPointSelector(
                                  context, widget.imagePath!);
                              if (stat == 1) {
                                if (context.mounted) {
                                  showSuccessSnackBar(
                                      context, "Predicting...", 0);
                                }
                                var predictVol = await performPortionPrediction(
                                    widget.imagePath!, () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                      title: Text("Connection Error"),
                                      content: Text(
                                          "Couldn't connect to the backend, please try again later."),
                                    ),
                                  );
                                });

                                if (predictVol != -1) {
                                  double density = double.parse(
                                      labelAttributes[entry.key]?["density"] ??
                                          "0");
                                  double caloriesPerGram = double.parse(
                                      labelAttributes[entry.key]
                                              ?["caloriesPerGram"] ??
                                          "0");
                                  predictedCalorie =
                                      predictVol * density * caloriesPerGram;
                                  if (context.mounted) {
                                    showSuccessSnackBar(context,
                                        "Calorie prediction completed", 1);
                                  }

                                  setState(() {
                                    predictedCalorie = predictedCalorie;
                                    this.totalCalorie = predictedCalorie;
                                    usePredictedCalories = true;
                                  });
                                } else {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const AlertDialog(
                                        title: Text("Unexpected prediction"),
                                        content: Text(
                                            "Please try again later and select the food properly."),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              // If the user pressed 'Cancel' or closed the dialog, we don't proceed
                              AppLogger.instance
                                  .i("User cancelled the prediction.");
                            }
                          }
                        },
                        child: const Text("Predict portion"),
                      )
                    ],
                  ),
                  Slider(
                    divisions: 4,
                    min: 1,
                    max: 5,
                    label: portionSliderValue.round().toString(),
                    value: portionSliderValue,
                    onChanged: usePredictedCalories
                        ? null
                        : (double value) {
                            setState(() {
                              portionSliderValue = value;
                              totalCalorie =
                                  initialCalories * portionSliderValue;
                            });
                          },
                  ),
                  Row(
                    children: [
                      usePredictedCalories
                          ? const Text("Predicted calories: ")
                          : const Text("Total calories: "),
                      Container(
                        decoration: BoxDecoration(
                          color: secondaryText.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${usePredictedCalories ? predictedCalorie.round() : totalCalorie.round()} kcal",
                            style: const TextStyle(color: primaryText),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: () {
                      if (portionSliderValue <= 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Incomplete details"),
                            content:
                                const Text("Please select the portion size."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      usePredictedCalories
                          ? addMeal(
                              entry,
                              (predictedCalorie / initialCalories).toInt() == 0
                                  ? 1
                                  : (predictedCalorie / initialCalories)
                                      .toInt(),
                              predictedCalorie,
                              widget.imagePath!)
                          : addMeal(entry, portionSliderValue.toInt(),
                              totalCalorie, widget.imagePath!);

                      showSuccessSnackBar(context,
                          "The meal has been added to your history!", 1);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Add this meal"),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
