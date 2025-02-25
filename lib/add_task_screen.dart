// add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Accept a task for editing

  AddTaskScreen({this.task, Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>(); // For validating the form
  late String _taskName; // Holds the task name
  late String _description; // Holds the task description
  DateTime? _selectedDate; // Holds the selected deadline date
  TextEditingController _daysController = TextEditingController(); // For inputting number of days
  String? _successMessage; // Holds the success message

  @override
  void initState() {
    super.initState();
    // Initialize fields if editing
    if (widget.task != null) {
      _taskName = widget.task!.title;
      _description = widget.task!.description;
      _selectedDate = widget.task!.deadline;
    } else {
      _taskName = '';
      _description = '';
    }
  }

  Future<void> _insertOrUpdateTask(String taskName, String description, DateTime deadline) async {
    try {
      final db = await DatabaseHelper().database;
      if (widget.task != null) {
        // Update existing task
        await db.update(
          'tasks',
          {
            'title': taskName,
            'description': description,
            'deadline': deadline.toIso8601String(),
            'isCompleted': widget.task!.isCompleted ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [widget.task!.id],
        );
      } else {
        // Insert new task
        await db.insert(
          'tasks',
          {
            'title': taskName,
            'description': description,
            'deadline': deadline.toIso8601String(),
            'isCompleted': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('Error inserting/updating task: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Current date or selected date
      firstDate: DateTime.now(), // No past dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Add a Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Changed to ListView to prevent overflow
            children: [
              TextFormField(
                initialValue: _taskName,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _taskName = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
                onChanged: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Deadline Date'),
                  ),
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.task == null)
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Or enter days for deadline',
                    hintText: 'e.g. 10 days',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // It's optional
                    }
                    final int? days = int.tryParse(value);
                    if (days == null || days < 1) {
                      return 'Enter a valid number of days';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              // Display the success message if it's set
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop(); // Go back without saving
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Calculate deadline if days were entered and not editing
                        if (widget.task == null && _daysController.text.isNotEmpty) {
                          int days = int.parse(_daysController.text);
                          _selectedDate = DateTime.now().add(Duration(days: days));
                        }

                        if (_selectedDate != null) {
                          await _insertOrUpdateTask(_taskName, _description, _selectedDate!);
                          if (mounted) {
                            setState(() {
                              _successMessage = widget.task != null
                                  ? 'Task updated successfully'
                                  : 'Task saved successfully';

                              // Optionally reset the form fields
                              _formKey.currentState?.reset();
                              _daysController.clear();
                              _selectedDate = null;
                            });

                            // Navigate back to the previous screen
                            Navigator.of(context).pop();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select or enter a deadline')),
                          );
                        }
                      }
                    },
                    child: Text(widget.task != null ? 'Update Task' : 'Save Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _daysController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
  }
}
