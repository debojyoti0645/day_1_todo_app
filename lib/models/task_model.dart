import 'package:intl/intl.dart'; // For date formatting in UI

enum TaskPriority { low, medium, high }
enum TaskCategory { work, personal, shopping, health, finance, other }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  TaskPriority priority;
  TaskCategory category;
  bool hasReminder; // New field for reminder
  Duration reminderOffset; // New field for reminder offset (e.g., 15 mins before)

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.hasReminder = false,
    this.reminderOffset = Duration.zero, // Default to no offset
  });

  // Convert Task object to a Map for JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(), // Store as ISO 8601 string
        'isCompleted': isCompleted,
        'priority': priority.index, // Store enum index
        'category': category.index, // Store enum index
        'hasReminder': hasReminder,
        'reminderOffsetSeconds': reminderOffset.inSeconds, // Store duration in seconds
      };

  // Create Task object from a Map (JSON deserialization)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      priority: TaskPriority.values[json['priority']],
      category: TaskCategory.values[json['category']],
      hasReminder: json['hasReminder'] ?? false,
      reminderOffset: Duration(seconds: json['reminderOffsetSeconds'] ?? 0),
    );
  }

  // Helper to check if two DateTimes represent the same day (ignoring time)
  bool isSameDay(DateTime other) {
    return dueDate.year == other.year &&
        dueDate.month == other.month &&
        dueDate.day == other.day;
  }

  // Helper to format due date for display
  String get formattedDueDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(dueDate);
  }
}
