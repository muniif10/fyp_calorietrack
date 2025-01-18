import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enable Firestore persistence for offline caching
  FirestoreHelper() {
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  // Stream for real-time updates
  Stream<List<Meal>> mealsStream() {
    CollectionReference mealsCollection = _getUserMealsCollection();
    return mealsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Meal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Function to get the current user's meals collection
  CollectionReference _getUserMealsCollection() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    return _firestore.collection('users').doc(currentUser.uid).collection('food_history');
  }

  Future<void> addMeal(Meal meal) async {
    try {
      CollectionReference mealsCollection = _getUserMealsCollection();
      await mealsCollection.add(meal.toMap());
    } catch (e) {
      AppLogger.instance.e("Error adding meal: $e");
    }
  }

  Future<void> updateMeal(String docId, Meal meal) async {
    try {
      CollectionReference mealsCollection = _getUserMealsCollection();
      await mealsCollection.doc(docId).update(meal.toMap());
    } catch (e) {
      AppLogger.instance.e("Error updating meal: $e");
    }
  }

  Future<void> deleteMeal(String docId) async {
    try {
      CollectionReference mealsCollection = _getUserMealsCollection();
      await mealsCollection.doc(docId).delete();
    } catch (e) {
      AppLogger.instance.e("Error deleting meal: $e");
    }
  }

  Future<void> clearData() async {
    try {
      CollectionReference mealsCollection = _getUserMealsCollection();
      QuerySnapshot querySnapshot = await mealsCollection.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      AppLogger.instance.e("Error clearing data: $e");
    }
  }
}
