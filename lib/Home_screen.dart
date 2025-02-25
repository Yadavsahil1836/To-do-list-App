// home_screen.dart

import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';
import 'more_screen.dart';
import 'task_model.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _deadlineTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Schedule the timer after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDeadlineTimer();
    });
  }

  void _startDeadlineTimer() {
    _deadlineTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (mounted && !_isDisposed) _checkTaskDeadlines();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _deadlineTimer?.cancel();
    super.dispose();
  }

  Future<List<Task>> _getTasksFromDatabase() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  void _checkTaskDeadlines() {
    if (!mounted || _isDisposed) return;
    _getTasksFromDatabase().then((tasks) {
      for (Task task in tasks) {
        if (DateTime.now().isAfter(task.deadline) && !task.isCompleted) {
          _showDeadlineNotification(task);
        }
      }
    });
  }

  Future<void> _showDeadlineNotification(Task task) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Task deadline passed!'),
        content: Text('You missed the deadline for "${task.title}"'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _deleteTask(Task task) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );
    setState(() {}); // Refresh UI after deleting a task
  }

  void _editTask(Task task) async {
    // Navigate to AddTaskScreen with task data for editing
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: task),
      ),
    );
    setState(() {}); // Refresh UI after editing a task
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: [
            FutureBuilder<List<Task>>(
              future: _getTasksFromDatabase(),
              builder: (buildContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks'));
                } else {
                  final tasks = snapshot.data ?? [];
                  return HomeScreenBody(tasks, _editTask, _deleteTask);
                }
              },
            ),
            const CalendarScreen(),
            AddTaskScreen(),
            const NotificationsScreen(),
            MoreScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        color: Colors.blue,
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 30),
          Icon(Icons.calendar_today, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.notifications, size: 30),
          Icon(Icons.more_horiz, size: 30),
        ],
        onTap: onTabTapped,
      ),
    );
  }
}

class HomeScreenBody extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task task) onEditTask;
  final Function(Task task) onDeleteTask;

  const HomeScreenBody(this.tasks, this.onEditTask, this.onDeleteTask, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello Sahil Yadav!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                backgroundImage: AssetImage('images/profile.jpg'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Your tasks',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks yet! Add a new task.'))
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1, // Square cards
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle task tap if needed
                        },
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        onEditTask(task);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        onDeleteTask(task);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
