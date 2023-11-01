import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'habit.dart';

class AssetManager {
  static const suggestedHabitsPath = "assets/suggested_habits.json";

  static List<Habit> suggestedHabits = [];

  static Future<List<dynamic>> readSuggestedHabits() async {
    try {
      final jsonString =
          await rootBundle.loadString(suggestedHabitsPath);
      final jsonData = json.decode(jsonString);

      if (jsonData.isNotEmpty) {
        final List<dynamic> habitNames = jsonData["habits"].map((habit) {
          suggestedHabits.add(
            Habit(
              habit["name"],
              habit["isCompleted"],
              habit["description"],
              habit["icon"],
              habit["notificationTime"],
              habit["miscData"],
            )
          );

          return habit['name'].toString();
        }).toList();

        return habitNames;
      } else {
        if (kDebugMode) {
          print('JSON file is empty.');
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error loading JSON file: $error');
      }
      return [];
    }
  }
}
