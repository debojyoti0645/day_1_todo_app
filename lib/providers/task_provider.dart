import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  static const String _tasksKey = 'tasks';

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks(); // Load tasks when the provider is initialized
  }

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson != null) {
      final List<dynamic> taskMaps = jsonDecode(tasksJson);
      _tasks = taskMaps.map((map) => Task.fromJson(map)).toList();
      notifyListeners();
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> taskMaps = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(taskMaps));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Keep tasks sorted by due date
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }
}