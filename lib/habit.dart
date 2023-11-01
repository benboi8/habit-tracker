import 'package:flutter/material.dart';

import 'asset_manager.dart';

class Habit {
  static List<Habit> habits = [];

  String name;
  Icon icon;
  String description;
  String notificationTime;
  String miscData;

  bool isCompleted;

  Habit(this.name, this.isCompleted, this.description, this.icon, this.notificationTime, this.miscData);

  // Factory function to create a Habit with only the name
  factory Habit.withName(String name) {
    return Habit(
      name,
      false, // Default value for isCompleted
      "No Description", // Default value for description
      const Icon(Icons.star), // Default value for icon
      "Never", // Default value for notificationTime
      'None', // Default value for miscData
    );
  }
}



class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  HabitTrackerPageState createState() => HabitTrackerPageState();
}

class HabitTrackerPageState extends State<HabitTrackerPage> {
  TextEditingController habitController = TextEditingController();

  void _addHabit(String habitName) {
    setState(() {
      Habit.habits.add(Habit.withName(habitName));
    });
  }

  Future<void> _showHabitDetailsDialog(Habit habit) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(habit.name),
          content: Text(habit.description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> suggestedNames = [];

    AssetManager.readSuggestedHabits().then((List<dynamic> names) {
      for (String name in names) {
        suggestedNames.add(
          ActionChip(
            label: Text(name),
            onPressed: () {
              habitController.text = name;
            },
          ),
        );
        suggestedNames.add(const SizedBox(width: 5));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: Habit.habits.length,
        itemBuilder: (context, index) {
          final habit = Habit.habits[index];
          return GestureDetector(
            onTap: () {
              _showHabitDetailsDialog(habit);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.star,
                      size: 48,
                      color: habit.isCompleted ? Colors.green : Colors.grey),
                  Text(habit.name, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add a New Habit'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: habitController,
                      textCapitalization: TextCapitalization
                          .sentences, // Auto-capitalize first letter
                      decoration: const InputDecoration(
                        hintText: 'Habit Name',
                      ),
                    ),
                    suggestedNames.isNotEmpty
                        ? const SizedBox(height: 8)
                        : Container(),
                    suggestedNames.isNotEmpty
                        ? const Row(
                            children: <Widget>[
                              Icon(Icons.lightbulb, color: Colors.yellow),
                              SizedBox(width: 8),
                              Text('Suggested Names:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Container(),
                    suggestedNames.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: suggestedNames),
                          )
                        : Container(),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (habitController.text.isNotEmpty) {
                        _addHabit(
                            habitController.text);
                        habitController.clear();
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    habitController.dispose();
    super.dispose();
  }
}
