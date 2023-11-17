import 'package:best_todo_app/models/model.dart';
import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final Function(String, String) onEdit;
  final Function onComplete;

  const TaskTile(
      {required this.task, required this.onEdit, required this.onComplete});

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  TextEditingController? _editController;
  TextEditingController? _editDescriptionController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.task.title);
    _editDescriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: isEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _editController,
                  onSubmitted: (newTitle) {
                    widget.onEdit(newTitle, _editDescriptionController!.text);
                    setState(() {
                      isEditing = false;
                    });
                  },
                ),
                TextField(
                  controller: _editDescriptionController,
                  onSubmitted: (newDescription) {
                    widget.onEdit(_editController!.text, newDescription);
                    setState(() {
                      isEditing = false;
                    });
                  },
                ),
              ],
            )
          : Text(widget.task.title),
      subtitle: isEditing
          ? null
          : widget.task.description.isNotEmpty
              ? Text(widget.task.description)
              : null,
      onTap: () {
        setState(() {
          isEditing = !isEditing;
        });
      },
      onLongPress: () => widget.onComplete(), // Use () => to fix the error
    );
  }
}
