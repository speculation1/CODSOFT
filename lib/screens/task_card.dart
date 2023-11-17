import 'package:best_todo_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function onDelete;

  const TaskCard({super.key, required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final completedTime = task.completedTime != null
        ? DateFormat('dd-MM-yyyy hh:mm a').format(task.completedTime!)
        : '';

    return Dismissible(
      key: Key(task.title),
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(
          title: Text(task.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed on: $completedTime'),
              if (task.description.isNotEmpty)
                Text('Description: ${task.description}'),
            ],
          ),
        ),
      ),
    );
  }
}
