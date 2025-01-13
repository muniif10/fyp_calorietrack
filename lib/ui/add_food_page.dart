import 'dart:convert';
import 'dart:io';
import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:calorie_track/ui/prediction_modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

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

class _AddFoodPageState extends State<AddFoodPage> {
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

  void addMeal(MapEntry<String, double> entry, int portion, double calories,
      String imagePath) {
    DatabaseHelper db = DatabaseHelper.instance;
    db.insertMeal(Meal(
        foodName: entry.key,
        calorieInput: calories,
        portion: portion,
        insertionDate: DateTime.now().toIso8601String(),
        imagePath: imagePath));
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
        double vol_pred_double = responseMap['food_volume_cm3'];
        int foodVolPrediction = vol_pred_double.toInt();
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
                                style: TextStyle(
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
                          int stat = await _showPointSelector(
                              context, widget.imagePath!);
                          if (stat == 1) {
                            var predictVol = await performPortionPrediction(
                                widget.imagePath!, () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
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

                              setState(() {
                                this.predictedCalorie = predictedCalorie;
                                this.totalCalorie = predictedCalorie;
                                usePredictedCalories = true;
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Unexpected prediction"),
                                  content: Text(
                                      "Please try again later and select the food properly."),
                                ),
                              );
                            }
                          }
                        },
                        child: Text("Predict portion"),
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
                            style: TextStyle(color: primaryText),
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
                              (predictedCalorie / initialCalories).toInt(),
                              predictedCalorie,
                              widget.imagePath!)
                          : addMeal(entry, portionSliderValue.toInt(),
                              totalCalorie, widget.imagePath!);

                      showSuccessSnackBar(context);
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
