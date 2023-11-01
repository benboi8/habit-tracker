import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      const Icon(Icons.star, size: 48,), // Default value for icon
      "Never", // Default value for notificationTime
      'None', // Default value for miscData
    );
  }
}

class HabitDetailPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailPage({Key? key, required this.habit}) : super(key: key);

  @override
  HabitDetailPageState createState() => HabitDetailPageState();
}

class HabitDetailPageState extends State<HabitDetailPage> {
  late final Habit habit;

  @override
  void initState() {
    super.initState();

    habit = widget.habit;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: habit.name);
    TextEditingController descriptionController = TextEditingController(text: habit.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                habit.icon,
                const SizedBox(width: 8),
                // Display the name as a TextField
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.habitName,
                    ),
                    controller: nameController,
                    onSubmitted: (value) {
                      // Update the habit name when text changes
                      setState(() {
                        habit.name = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitDescription, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Display the description as a TextField
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.habitDescription,
              ),
              controller: descriptionController,
              onSubmitted: (value) {
                // Update the habit description when text changes
                setState(() {
                  habit.description = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitNotificationTime, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(habit.notificationTime),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitMiscData, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(habit.miscData),
          ],
        ),
      ),
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

  void _addSuggestedHabit(String name) {
    setState(() {
      Habit.habits.add(AssetManager.suggestedHabits.firstWhere((element) => element.name == name));
      Navigator.of(context).pop();
    });
  }

  void _showHabitDetails(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailPage(habit: habit),
      ),
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
              _addSuggestedHabit(name);
            },
          ),
        );
        suggestedNames.add(const SizedBox(width: 5));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
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
              _showHabitDetails(habit);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  habit.icon,
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
                title: Text(AppLocalizations.of(context)!.addNewHabit),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: habitController,
                      textCapitalization: TextCapitalization.sentences, // Auto-capitalize first letter
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.habitHint,
                      ),
                    ),
                    suggestedNames.isNotEmpty
                        ? const SizedBox(height: 8)
                        : Container(),
                    suggestedNames.isNotEmpty
                        ? Row(
                            children: <Widget>[
                              const Icon(Icons.lightbulb, color: Colors.yellow),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.suggestedHabits,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
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
                        _addHabit(habitController.text);
                        habitController.clear();
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.addHabit),
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
