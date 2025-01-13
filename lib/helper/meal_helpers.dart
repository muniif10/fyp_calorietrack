// Assuming this is your updated labels list (from labels.txt)
final List<String> labels = [
  "laksa_penang",
  "laksa_terengganu",
  "nasi_dagang",
  "nasi_kerabu",
  "nasi_lemak",
  "cheesecake",
  "chicken_curry",
  "dumplings",
  "fried_rice",
  "hamburger",
  "pancakes",
  "pizza",
  "spaghetti_bolognese",
  "spaghetti_carbonara",
  "waffles"
];

// Function to convert the label into a human-readable name
String getHumanReadableName(String label) {
  // Convert label like 'laksa_penang' into 'Laksa Penang'
  return label.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}

// Add attributes associated with each label (e.g., categories, descriptions, calories, etc.)
Map<String, Map<String, String>> labelAttributes = {
  "laksa_penang": {
    "category": "Main",
    "description": "A spicy and tangy noodle soup from Penang with a rich tamarind base.",
    "calories": "430",
    "density": "1.0", // g/mL
    "caloriesPerGram": "2.16", // Cal/g
  },
  "laksa_terengganu": {
    "category": "Main",
    "description": "A type of laksa from Terengganu, served with rice noodles and a rich fish-based broth.",
    "calories": "380",
    "density": "1.0", // g/mL
    "caloriesPerGram": "1.76", // Cal/g
  },
  "nasi_dagang": {
    "category": "Main",
    "description": "A Malaysian rice dish served with fish and coconut.",
    "calories": "158",
    "density": "0.8", // g/mL
    "caloriesPerGram": "2.04", // Cal/g
  },
  "nasi_kerabu": {
    "category": "Main",
    "description": "A colorful Malaysian rice dish often served with herbs, vegetables, and meat.",
    "calories": "250",
    "density": "0.8", // g/mL
    "caloriesPerGram": "1.04", // Cal/g
  },
  "nasi_lemak": {
    "category": "Main",
    "description": "A Malaysian rice dish cooked in coconut milk, usually served with sambal, egg, and cucumber.",
    "calories": "587",
    "density": "0.8", // g/mL
    "caloriesPerGram": "1.93", // Cal/g
  },
  "cheesecake": {
    "category": "Dessert",
    "description": "A sweet dessert made from cream cheese.",
    "calories": "321",
    "density": "1.2", // g/mL
    "caloriesPerGram": "2.68", // Cal/g
  },
  "chicken_curry": {
    "category": "Main",
    "description": "A flavorful dish made with chicken and a mix of spices, often served with rice.",
    "calories": "320",
    "density": "1.1", // g/mL
    "caloriesPerGram": "1.45", // Cal/g
  },
  "dumplings": {
    "category": "Snack",
    "description": "Dough-filled parcels often stuffed with meat, vegetables, or seafood.",
    "calories": "200",
    "density": "1.0", // g/mL
    "caloriesPerGram": "2.00", // Cal/g
  },
  "fried_rice": {
    "category": "Main",
    "description": "Rice stir-fried with vegetables and meat.",
    "calories": "130",
    "density": "0.9", // g/mL
    "caloriesPerGram": "1.44", // Cal/g
  },
  "hamburger": {
    "category": "Main",
    "description": "A ground beef patty in a bun.",
    "calories": "250",
    "density": "1.2", // g/mL
    "caloriesPerGram": "2.08", // Cal/g
  },
  "pancakes": {
    "category": "Dessert",
    "description": "Fluffy, round cakes made from batter, often served with syrup or toppings.",
    "calories": "350",
    "density": "0.8", // g/mL
    "caloriesPerGram": "1.75", // Cal/g
  },
  "pizza": {
    "category": "Main",
    "description": "A flatbread topped with cheese, tomato sauce, and various toppings.",
    "calories": "266",
    "density": "1.0", // g/mL
    "caloriesPerGram": "2.66", // Cal/g
  },
  "spaghetti_bolognese": {
    "category": "Main",
    "description": "Spaghetti served with a meat-based tomato sauce.",
    "calories": "131",
    "density": "0.9", // g/mL
    "caloriesPerGram": "1.46", // Cal/g
  },
  "spaghetti_carbonara": {
    "category": "Main",
    "description": "Spaghetti served with a creamy egg and cheese sauce.",
    "calories": "157",
    "density": "0.9", // g/mL
    "caloriesPerGram": "1.74", // Cal/g
  },
  "waffles": {
    "category": "Dessert",
    "description": "A crisp, patterned batter cake, often served with toppings.",
    "calories": "291",
    "density": "0.8", // g/mL
    "caloriesPerGram": "1.82", // Cal/g
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
      "density": attributes["density"]!,
      "caloriesPerGram": attributes["caloriesPerGram"]!,
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
