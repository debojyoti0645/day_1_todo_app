import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Add uuid package for unique IDs
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // Null if adding new, not null if editing
  final DateTime? initialDate; // For setting initial date from calendar

  const AddEditTaskScreen({super.key, this.task, this.initialDate});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  late bool _hasReminder;
  late Duration _reminderOffset;

  final List<Duration> _reminderOffsets = [
    Duration.zero, // No reminder
    const Duration(minutes: 5),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(days: 1),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Editing existing task
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(
        text: widget.task!.description,
      );
      _selectedDueDate = widget.task!.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      _selectedPriority = widget.task!.priority;
      _selectedCategory = widget.task!.category;
      _hasReminder = widget.task!.hasReminder;
      _reminderOffset = widget.task!.reminderOffset;
    } else {
      // Adding new task
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDueDate = widget.initialDate ?? DateTime.now();
      _selectedDueTime = TimeOfDay.now();
      _selectedPriority = TaskPriority.medium;
      _selectedCategory = TaskCategory.other;
      _hasReminder = false;
      _reminderOffset = Duration.zero;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper to normalize date to remove time components for consistent comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _normalizeDate(
        _selectedDueDate,
      ), // Ensure initial date is normalized
      firstDate: _normalizeDate(DateTime.now()), // Prevent selecting past days
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // AppBar color
              onPrimary:
                  Theme.of(
                    context,
                  ).colorScheme.onPrimary, // Text/icon color on AppBar
              surface:
                  Theme.of(
                    context,
                  ).cardColor, // Background of the picker itself
              onSurface:
                  Theme.of(
                    context,
                  ).colorScheme.onSurface, // Text/icon color on picker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // OK/Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _normalizeDate(_selectedDueDate)) {
      // Compare normalized dates
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueTime) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  String _formatReminderOffset(Duration offset) {
    if (offset == Duration.zero) return 'No reminder';
    if (offset.inDays > 0)
      return '${offset.inDays} day${offset.inDays > 1 ? 's' : ''} before';
    if (offset.inHours > 0)
      return '${offset.inHours} hour${offset.inHours > 1 ? 's' : ''} before';
    if (offset.inMinutes > 0)
      return '${offset.inMinutes} minute${offset.inMinutes > 1 ? 's' : ''} before';
    return 'At due time'; // Should not happen with current offsets
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final combinedDueDate = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedDueTime.hour,
        _selectedDueTime.minute,
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.task == null) {
        // Add new task
        final newTask = Task(
          id: const Uuid().v4(), // Generate unique ID
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: combinedDueDate,
          priority: _selectedPriority,
          category: _selectedCategory,
          hasReminder: _hasReminder,
          reminderOffset: _reminderOffset,
        );
        taskProvider.addTask(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      } else {
        // Edit existing task
        final updatedTask = Task(
          id: widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: combinedDueDate,
          isCompleted:
              widget.task!.isCompleted, // Keep original completion status
          priority: _selectedPriority,
          category: _selectedCategory,
          hasReminder: _hasReminder,
          reminderOffset: _reminderOffset,
        );
        taskProvider.updateTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
      }
      Navigator.of(context).pop(); // Go back to home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Buy groceries',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., Milk, eggs, bread',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 24),
              // Due Date & Time Pickers
              Text(
                'Due Date & Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: DateFormat(
                              'MMM dd, yyyy',
                            ).format(_selectedDueDate),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _selectedDueTime.format(context),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority Selector
              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children:
                    TaskPriority.values.map((priority) {
                      return ChoiceChip(
                        label: Text(priority.name.capitalize()),
                        selected: _selectedPriority == priority,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Category Selector
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children:
                    TaskCategory.values.map((category) {
                      return ChoiceChip(
                        label: Text(category.name.capitalize()),
                        selected: _selectedCategory == category,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.2),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Reminder Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Reminder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: _hasReminder,
                    onChanged: (value) {
                      setState(() {
                        _hasReminder = value;
                        if (!value)
                          _reminderOffset =
                              Duration.zero; // Reset if reminder off
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              if (_hasReminder)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: DropdownButtonFormField<Duration>(
                    value: _reminderOffset,
                    decoration: const InputDecoration(
                      labelText: 'Remind me',
                      hintText: 'Select reminder time',
                    ),
                    items:
                        _reminderOffsets.map((offset) {
                          return DropdownMenuItem<Duration>(
                            value: offset,
                            child: Text(_formatReminderOffset(offset)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _reminderOffset = value!;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Save Button (redundant with AppBar action, but good for visibility)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(
                    widget.task == null ? 'Create Task' : 'Update Task',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize enum names for display
extension StringCasingExtension on String {
  String capitalize() =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
}
