import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task_model.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Define the selected day and focused day
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Map to hold events (tasks) for each day
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from the database
  }

  Future<void> _loadTasks() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    List<Task> tasks = maps.map((map) => Task.fromMap(map)).toList();

    // Group tasks by date
    Map<DateTime, List<Task>> events = {};
    for (var task in tasks) {
      final date = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      if (events[date] == null) {
        events[date] = [task];
      } else {
        events[date]!.add(task);
      }
    }

    setState(() {
      _events = events;
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        title: const Text('Calendar'),
        // backgroundColor: Colors.transparent,
        // iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getTasksForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _getTasksForDay(_selectedDay);

    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks for this day.'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Text(
            'Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
          ),
        );
      },
    );
  }
}
