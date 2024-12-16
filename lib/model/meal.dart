class Meal {
  final int id;
  final String foodName;
  final String insertionDate;
  final double calorieInput;
  final int portion;

  Meal({
    required this.id,
    required this.foodName,
    required this.insertionDate,
    required this.calorieInput,
    required this.portion,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'insertion_date': insertionDate,
      'calorie_input': calorieInput,
      'portion': portion,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      foodName: map['food_name'],
      insertionDate: map['insertion_date'],
      calorieInput: map['calorie_input'],
      portion: map['portion'],
    );
  }
}
