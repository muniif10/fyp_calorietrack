
// Assuming this is your labels list (from labels.txt)
final List<String> labels = [
  "cheesecake",
  "donuts",
  "french_fries",
  "fried_rice",
  "hamburger",
  "ice_cream",
  "karipap",
  "nasi_dagang",
  "nasi_kandar",
  "nasi_lemak",
  "pisang_goreng",
  "pizza",
  "spaghetti_bolognese",
  "spaghetti_carbonara",
  "waffles"
];

// Function to convert the label into a human-readable name
String getHumanReadableName(String label) {
  // Convert label like 'nasi_lemak' into 'Nasi Lemak'
  return label.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}

// Add attributes associated with each label (e.g., categories, descriptions, calories, etc.)
Map<String, Map<String, String>> labelAttributes = {
  "cheesecake": {
    "category": "Dessert",
    "description": "A sweet dessert made from cream cheese.",
    "calories": "321",
  },
  "donuts": {
    "category": "Snack",
    "description": "A fried dough confectionery, often sweetened.",
    "calories": "452",
  },
  "french_fries": {
    "category": "Snack",
    "description": "Deep-fried potato slices.",
    "calories": "365",
  },
  "fried_rice": {
    "category": "Main",
    "description": "Rice stir-fried with vegetables and meat.",
    "calories": "130",
  },
  "hamburger": {
    "category": "Main",
    "description": "A ground beef patty in a bun.",
    "calories": "250",
  },
  "ice_cream": {
    "category": "Dessert",
    "description": "A frozen dessert made from dairy products.",
    "calories": "207",
  },
  "karipap": {
    "category": "Snack",
    "description": "A Malay pastry filled with curried potatoes.",
    "calories": "250",
  },
  "nasi_dagang": {
    "category": "Main",
    "description": "A Malaysian rice dish served with fish and coconut.",
    "calories": "158",
  },
  "nasi_kandar": {
    "category": "Main",
    "description": "A Malaysian rice dish served with curries.",
    "calories": "210",
  },
  "nasi_lemak": {
    "category": "Main",
    "description": "A Malaysian rice dish cooked in coconut milk.",
    "calories": "250",
  },
  "pisang_goreng": {
    "category": "Snack",
    "description": "Fried banana, a popular snack in Southeast Asia.",
    "calories": "150",
  },
  "pizza": {
    "category": "Main",
    "description": "A flatbread topped with cheese, tomato sauce, and various toppings.",
    "calories": "266",
  },
  "spaghetti_bolognese": {
    "category": "Main",
    "description": "Spaghetti served with a meat-based tomato sauce.",
    "calories": "131",
  },
  "spaghetti_carbonara": {
    "category": "Main",
    "description": "Spaghetti served with a creamy egg and cheese sauce.",
    "calories": "157",
  },
  "waffles": {
    "category": "Dessert",
    "description": "A crisp, patterned batter cake, often served with toppings.",
    "calories": "291",
  },
};

// Function to get a readable list of predictions with their associated attributes
Future<List<Map<String, String>>> getFormattedPredictionList(List<double> predictionValues) async {
  // Get the sorted prediction map first
  var sortedPredictionMap = await getSortedPredictionMap(predictionValues);

  // Format each prediction entry with the human-readable name, category, description, prediction value, and calories
  List<Map<String, String>> formattedPredictionList = [];
  
  sortedPredictionMap.forEach((label, predictionValue) {
    var humanReadableName = getHumanReadableName(label);
    var attributes = labelAttributes[label] ?? {"category": "Unknown", "description": "No description available.", "calories": "N/A"};
    
    formattedPredictionList.add({
      "name": humanReadableName,
      "category": attributes["category"]!,
      "description": attributes["description"]!,
      "calories": attributes["calories"]!,
      "prediction_value": predictionValue.toStringAsFixed(2),
    });
  });

  return formattedPredictionList;
}

// Function to get the sorted prediction map based on prediction values
Future<Map<String, double>> getSortedPredictionMap(List<double> predictionValues) async {
  // Create a map with label as the key and the corresponding prediction value as the value
  Map<String, double> predictionMap = {};

  for (int i = 0; i < predictionValues.length; i++) {
    predictionMap[labels[i]] = predictionValues[i];
  }

  // Sort the map by the prediction value in descending order
  var sortedPredictionMap = Map.fromEntries(
    predictionMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)), // Sorting in descending order
  );

  return sortedPredictionMap;
}
