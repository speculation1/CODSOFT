import 'dart:convert';

class Task {
  String title;
  String description;
  bool isCompleted;
  DateTime? completedTime;
  DateTime? reminderTime;

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.completedTime,
    required this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completedTime': completedTime!.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(), // Added reminderTime
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? completedTime = map['completedTime'] != null
        ? DateTime.parse(map['completedTime'])
        : null;

    DateTime? reminderTime = map['reminderTime'] != null
        ? DateTime.parse(map['reminderTime'])
        : null;

    return Task(
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      completedTime: completedTime,
      reminderTime: reminderTime, // Added reminderTime
    );
  }

  String toJSON() => json.encode(toMap());

  factory Task.fromJSON(String source) => Task.fromMap(json.decode(source));
}
