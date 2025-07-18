import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;
  late ScrollController _calendarScrollController;
  final GlobalKey _calendarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalizeDate(DateTime.now());
    _calendarScrollController = ScrollController();

    // Ensure tasks are loaded when the Home Page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  // Normalize date to remove time components for consistent comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Scroll to the selected date in the calendar on initial load
  void _scrollToSelectedDate() {
    final today = _normalizeDate(DateTime.now());
    final initialDate = today.subtract(
      const Duration(days: 30),
    ); // Start date for calendar
    final todayIndex = today.difference(initialDate).inDays;

    // Approximate widths for calendar items
    const double unselectedItemWidth = 70;
    const double selectedItemWidth = 90; // The width of the selected/today item

    // A small delay to ensure the ListView is built before attempting to scroll
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_calendarScrollController.hasClients) {
        final double screenWidth = MediaQuery.of(context).size.width;

        // Calculate scroll position to center the 'today' item
        // Sum of widths of unselected items before today + half of today's item width - half of screen width
        final double scrollPosition =
            (todayIndex * unselectedItemWidth) +
            (selectedItemWidth / 2) -
            (screenWidth / 2)+240;

        _calendarScrollController.animateTo(
          scrollPosition.clamp(
            0.0,
            _calendarScrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Get highlight color for calendar day based on tasks
  Color _getCalendarDayHighlightColor(
    DateTime date,
    List<Task> allTasks,
    BuildContext context,
  ) {
    final dayTasks = allTasks.where((task) => task.isSameDay(date)).toList();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (dayTasks.isEmpty) {
      return isDarkMode
          ? Colors.blue.shade800
          : Colors.blue.shade100; // No tasks: Blue
    }

    final allCompleted = dayTasks.every((task) => task.isCompleted);
    final allIncomplete = dayTasks.every((task) => !task.isCompleted);

    if (allCompleted) {
      return isDarkMode
          ? Colors.green.shade800
          : Colors.green.shade100; // All completed: Green
    } else if (allIncomplete) {
      return isDarkMode
          ? Colors.yellow.shade800
          : Colors.yellow.shade100; // All incomplete: Yellow
    } else {
      return isDarkMode
          ? Colors.orange.shade800
          : Colors.orange.shade100; // Mixed: Orange
    }
  }

  // Get border color for selected/current day
  Color _getBorderColor(DateTime date, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final normalizedToday = _normalizeDate(DateTime.now());

    if (_normalizeDate(date) == _selectedDate) {
      return Theme.of(context).colorScheme.primary; // Selected day border
    } else if (_normalizeDate(date) == normalizedToday) {
      return isDarkMode
          ? Colors.cyan.shade300
          : Colors.blue.shade700; // Current day border
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;
    final tasksForSelectedDay =
        allTasks.where((task) => task.isSameDay(_selectedDate)).toList();

    // Sort tasks: incomplete first, then by due date
    tasksForSelectedDay.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.dueDate.compareTo(b.dueDate);
      }
      return a.isCompleted ? 1 : -1; // Incomplete tasks come before completed
    });

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Scrollable Calendar
          Container(
            key: _calendarKey,
            height: 95, // Height for calendar row
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              controller: _calendarScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 60, // e.g., 30 days before and 30 days after today
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(
                  Duration(days: 30 - index),
                );
                final normalizedDate = _normalizeDate(date);
                final isSelected = normalizedDate == _selectedDate;
                final isToday =
                    _normalizeDate(date) == _normalizeDate(DateTime.now());

                final dayHighlightColor = _getCalendarDayHighlightColor(
                  date,
                  allTasks,
                  context,
                );
                final borderColor = _getBorderColor(date, context);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = normalizedDate;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? 90 : 70, // Expand selected day
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: dayHighlightColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected || isToday ? 2.5 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'EEE',
                          ).format(date), // Day of week (e.g., Mon)
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                isToday &&
                                        !isDarkMode // Black for current day in light mode
                                    ? Colors.black
                                    : isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(date), // Day number (e.g., 18)
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                isToday &&
                                        !isDarkMode // Black for current day in light mode
                                    ? Colors.black
                                    : isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Text(
                            DateFormat('MMM').format(date), // Month (e.g., Jul)
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Task List for Selected Day
          Expanded(
            child:
                tasksForSelectedDay.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 70,
                            color: Theme.of(
                              context,
                            ).colorScheme.onBackground.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for this day!',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: tasksForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForSelectedDay[index];
                        return TaskCard(
                          task: task,
                          onToggleCompletion:
                              () => taskProvider.toggleTaskCompletion(task.id),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => AddEditTaskScreen(task: task),
                              ),
                            );
                          },
                          onDelete: () {
                            _showDeleteConfirmationDialog(context, task);
                          },
                        );
                      },
                    ),
          ),
          // Add Task Button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddEditTaskScreen(initialDate: _selectedDate),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Task'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteTask(task.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task "${task.title}" deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Reusable Task Card Widget
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color:
            task.isCompleted
                ? Theme.of(context).cardColor.withOpacity(0.7)
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? newValue) {
                    onToggleCompletion();
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          color:
                              task.isCompleted
                                  ? Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color
                                  : Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            task.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              decoration:
                                  task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Due: ${DateFormat('MMM dd, hh:mm a').format(task.dueDate)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Priority Indicator
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority, context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (!task
                    .isCompleted) // Show edit/delete only for incomplete tasks
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
