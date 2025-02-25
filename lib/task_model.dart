// task_model.dart

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : DateTime.now(),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
