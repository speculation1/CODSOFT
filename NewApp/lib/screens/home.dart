import 'package:best_todo_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:best_todo_app/screens/task_tile.dart';
import 'package:best_todo_app/screens/task_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool showReminder = false;
  String userName = "";
  DateTime currentTime = DateTime.now();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadUserName();
    initializeLocalNotifications();
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tasks = (prefs.getStringList('tasks') ?? [])
          .map((task) => Task.fromJSON(task))
          .toList();
    });
    checkAndShowReminder();
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks.map((task) => task.toJSON()).toList());
  }

  void scheduleTaskReminder(String taskTitle, DateTime reminderTime) async {
    // Use a dynamic channel ID
    const String channelId = 'channel_id';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      'channel_name', // <-- Channel Name
      // <-- Channel Description
      importance: Importance.max,
      priority: Priority.high,
    );

    // Create the NotificationDetails object
    NotificationDetails platformChannelSpecifics =
        const NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      taskTitle,
      'Task Reminder',
      tz.TZDateTime.from(reminderTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void completeTask(int index) {
    setState(() {
      tasks[index].isCompleted = true;
      tasks[index].completedTime = DateTime.now();
    });
    saveTasks();
    checkAndShowReminder();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
    checkAndShowReminder();
  }

  void checkAndShowReminder() {
    final undoneTasks = tasks.where((task) => !task.isCompleted).toList();
    if (undoneTasks.isNotEmpty) {
      setState(() {
        showReminder = true;
      });
    }
  }

  void loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "";
    });
  }

  void addTask(String taskTitle, String description, DateTime reminderTime) {
    setState(() {
      tasks.add(Task(
        title: taskTitle,
        description: description,
        completedTime: null,
        reminderTime: reminderTime,
      ));
    });
    _textController.clear();
    _descriptionController.clear();
    saveTasks();
    checkAndShowReminder();
    scheduleTaskReminder(taskTitle, reminderTime);
  }

  void editTask(int index, String newTaskTitle, String newDescription) {
    setState(() {
      tasks[index].title = newTaskTitle;
      tasks[index].description = newDescription;
    });
    saveTasks();
  }

  void initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    String greeting = getGreeting();

    tasks.sort((a, b) => a.isCompleted ? 1 : -1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello! - $userName',
          style: GoogleFonts.lato(fontSize: 30),
        ),
      ),
      body: Column(
        children: <Widget>[
          Text('Good $greeting, $userName!'),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                final task = tasks[index];
                if (task.isCompleted) {
                  return TaskCard(
                    task: task,
                    onDelete: () => deleteTask(index),
                  );
                } else {
                  return Dismissible(
                    key: Key(task.title),
                    onDismissed: (direction) {
                      deleteTask(index);
                    },
                    child: TaskTile(
                      task: task,
                      onEdit: (newTitle, newDescription) => editTask(
                        index,
                        newTitle,
                        newDescription,
                      ),
                      onComplete: () => completeTask(index),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: () {
          _dialogBuilder(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String getGreeting() {
    int hour = currentTime.hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Night';
    }
  }

  Future<void> _dialogBuilder(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: currentDate.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime reminderTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: TextField(
                controller: _textController,
                onSubmitted: (task) {
                  if (_textController.text.isNotEmpty) {
                    addTask(task, _descriptionController.text, reminderTime);
                  }
                  Navigator.of(context).pop();
                },
                decoration: const InputDecoration(
                  labelText: 'Add a new task',
                ),
              ),
              content: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      addTask(
                        _textController.text,
                        _descriptionController.text,
                        reminderTime,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
