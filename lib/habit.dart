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

  Habit(this.name, this.isCompleted, this.description, this.icon,
      this.notificationTime, this.miscData);

  // Factory function to create a Habit with only the name
  factory Habit.withName(String name) {
    return Habit(
      name,
      false, // Default value for isCompleted
      "No Description", // Default value for description
      const Icon(
        Icons.star,
        size: 48,
      ), // Default value for icon
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
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    habit = widget.habit;
    nameController = TextEditingController(text: habit.name);
    descriptionController = TextEditingController(text: habit.description);
  }

  Icon? unsavedIcon;

  void _showIconSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Adjust the number of columns as needed
              ),
              itemCount: AssetManager.habitIcons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Update the habit's icon when an icon is selected
                    setState(() {
                      unsavedIcon = Icon(
                        AssetManager.habitIcons[index],
                        size: 48,
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    AssetManager.habitIcons[index],
                    size: 48,
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    setState(() {});
  }

  bool _editingMode = false;

  void _saveChanges() {
    habit.name = nameController.text;
    habit.description = descriptionController.text;
    habit.icon = unsavedIcon ?? habit.icon;
  }

  void _cancelChanges() {
    nameController.text = habit.name;
    descriptionController.text = habit.description;
    unsavedIcon = null;
    _editingMode = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon:
                _editingMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                if (_editingMode) {
                  _saveChanges();
                  _editingMode = false;
                } else {
                  _editingMode = true;
                }
              });
            },
          ),
          _editingMode
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _cancelChanges();
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : Container()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _editingMode
                    ? IconButton(
                        icon: unsavedIcon ?? habit.icon,
                        onPressed: () {
                          _showIconSelectionDialog();
                        },
                      )
                    : habit.icon,
                const SizedBox(width: 8),
                // Display the name as a TextField
                _editingMode
                    ? Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.habitName,
                          ),
                          controller: nameController,
                          onSubmitted: (value) {
                            // Update the habit name when text changes
                            setState(() {
                              nameController.text = value;
                            });
                          },
                        ),
                      )
                    : Text(nameController.text),
              ],
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitDescription,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Display the description as a TextField
            _editingMode
                ? Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)?.habitDescription,
                      ),
                      controller: descriptionController,
                      onSubmitted: (value) {
                        // Update the habit description when text changes
                        setState(() {
                          descriptionController.text = value;
                        });
                      },
                    ),
                  )
                : Text(descriptionController.text),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitNotificationTime,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(habit.notificationTime),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.habitMiscData,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _showHabitDetails(Habit habit) async {
    // Needed to update the screen once details page is left
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailPage(habit: habit),
      ),
    ).then((value) {
      setState(() {

      });
    });
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
                      textCapitalization: TextCapitalization
                          .sentences, // Auto-capitalize first letter
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
                              Text(
                                  AppLocalizations.of(context)!.suggestedHabits,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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
