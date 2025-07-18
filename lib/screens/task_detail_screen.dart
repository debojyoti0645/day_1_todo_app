import 'package:day_1_todo_app/screens/add_edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart'; // Ensure this path is correct

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Color _getPriorityColor(TaskPriority priority, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case TaskPriority.high:
        return isDarkMode ? Colors.red.shade300 : Colors.red.shade700;
      case TaskPriority.medium:
        return isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700;
      case TaskPriority.low:
        return isDarkMode ? Colors.green.shade300 : Colors.green.shade700;
    }
  }

  String _formatReminderOffset(Duration offset) {
    if (offset == Duration.zero) return 'No reminder set';
    if (offset.inDays > 0) return '${offset.inDays} day${offset.inDays > 1 ? 's' : ''} before';
    if (offset.inHours > 0) return '${offset.inHours} hour${offset.inHours > 1 ? 's' : ''} before';
    if (offset.inMinutes > 0) return '${offset.inMinutes} minute${offset.inMinutes > 1 ? 's' : ''} before';
    return 'At due time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: task.isCompleted
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).textTheme.headlineMedium?.color,
                  ),
            ),
            const SizedBox(height: 16),
            if (task.description.isNotEmpty) ...[
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Due Date:',
              DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate),
            ),
            _buildDetailRow(
              context,
              Icons.access_time,
              'Due Time:',
              DateFormat('hh:mm a').format(task.dueDate),
            ),
            _buildDetailRowWithChip(
              context,
              Icons.flag,
              'Priority:',
              task.priority.name.capitalize(),
              _getPriorityColor(task.priority, context),
            ),
            _buildDetailRowWithChip(
              context,
              Icons.category,
              'Category:',
              task.category.name.capitalize(),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2), // Example color
            ),
            _buildDetailRow(
              context,
              Icons.check_circle_outline,
              'Status:',
              task.isCompleted ? 'Completed' : 'Pending',
              valueColor: task.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
            if (task.hasReminder)
              _buildDetailRow(
                context,
                Icons.notifications_active,
                'Reminder:',
                _formatReminderOffset(task.reminderOffset),
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // In a real app, you might allow editing from here
                  Navigator.of(context).pop(); // Go back to home
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to List'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithChip(
      BuildContext context, IconData icon, String label, String value, Color chipColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Chip(
              label: Text(value),
              backgroundColor: chipColor.withOpacity(0.2),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: chipColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}