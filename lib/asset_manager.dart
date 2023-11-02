import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'habit.dart';

class AssetManager {
  static const suggestedHabitsPath = "assets/suggested_habits.json";

  static List<Habit> suggestedHabits = [];

  static final List<IconData> habitIcons = [
    // Todo add more icons
    const IconData(0xe28d, fontFamily: 'MaterialIcons'),
    Icons.menu_book,
    Icons.spa,
    Icons.create,
    Icons.directions_walk,
    Icons.language,
    Icons.restaurant,
    Icons.self_improvement,
    Icons.directions_run,
    Icons.music_note,
    Icons.article,
    Icons.star,
    Icons.event_note,
    Icons.eco,
    Icons.movie,
    Icons.people,
    Icons.book,
    Icons.star,
    Icons.ac_unit,
    Icons.access_alarm,
    Icons.accessibility_new,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.account_tree,
    Icons.add_a_photo,
    Icons.call,
    Icons.water_drop,
  ];

  static Future<List<dynamic>> readSuggestedHabits() async {
    try {
      final jsonString = await rootBundle.loadString(suggestedHabitsPath);
      final jsonData = json.decode(jsonString);

      if (jsonData.isNotEmpty) {
        final List<dynamic> habitNames = jsonData["habits"].map((habit) {
          suggestedHabits.add(Habit(
            habit["name"],
            habit["isCompleted"],
            habit["description"],
            Icon(getIconFromString(habit["icon"]), size: 48,),
            habit["notificationTime"],
            habit["miscData"],
          ));

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

  static IconData getIconFromString(String iconName) {
    // todo get custom icons for some cases
    switch (iconName) {
      case 'Physical':
        return const IconData(0xe28d, fontFamily: 'MaterialIcons'); // Exercise
      case 'Reading':
        return Icons.menu_book; // Read
      case 'Meditation':
        return Icons.spa; // Meditate
      case 'Writing':
        return Icons.create; // Write
      case 'Walking':
        return Icons.directions_walk; // Walk
      case 'Language':
        return Icons.language; // Learn a new language
      case 'Cooking':
        return Icons.restaurant; // Cook a new meal
      case 'Yoga':
        return Icons.self_improvement; // Yoga
      case 'Running':
        return Icons.directions_run; // Run
      case 'Music':
        return Icons.music_note; // Practice Guitar
      case 'News':
        return Icons.article; // Read News
      case 'Mindfulness':
        return Icons.star; // Practice Mindfulness
      case 'Planning':
        return Icons.event_note; // Plan Your Day
      case 'Nature':
        return Icons.eco; // Take a Nature Walk
      case 'Documentary':
        return Icons.movie; // Watch a Documentary
      case 'Friend':
        return Icons.people; // Call a Friend
      case 'Journaling':
        return Icons.book; // Write in a Journal
      default:
        return Icons.star; // Default for unknown
    }
  }
}
