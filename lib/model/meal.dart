import 'dart:convert';
import 'dart:io';

class Meal {
  final String foodName;
  final String insertionDate;
  final double calorieInput;
  final int portion;
  final String imageBase64;

  Meal({
    required this.foodName,
    required this.insertionDate,
    required this.calorieInput,
    required this.portion,
    required this.imageBase64,
  }) {
    if (foodName.isEmpty) {
      throw ArgumentError('Food name cannot be empty');
    }
    if (calorieInput < 0) {
      throw ArgumentError('Calories cannot be negative');
    }
    if (portion < 1) {
      throw ArgumentError('Portion must be at least 1');
    }
  }

  // Encode the image file to base64
  static Future<String> encodeImageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  // Decode base64 to image bytes (if needed for display)
  static List<int> decodeBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  Map<String, dynamic> toMap() {
    return {
      'food_name': foodName,
      'insertion_date': insertionDate,
      'calorie_input': calorieInput,
      'portion': portion,
      'image_base64': imageBase64,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      foodName: map['food_name'],
      insertionDate: map['insertion_date'],
      calorieInput: map['calorie_input'],
      portion: map['portion'],
      imageBase64: map['image_base64'],
    );
  }
}
