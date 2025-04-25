import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  final List<String> _tasks = List<String>.generate(
      15, (index) => 'Task ${index + 1}: Do something important');
  final List<bool> _isChecked = List<bool>.generate(15, (index) => false);

  List<String> get tasks => _tasks;
  List<bool> get isChecked => _isChecked;

  void addTask(String title) {
    _tasks.add(title);
    _isChecked.add(false);
    notifyListeners();
  }

  void toggleChecked(int index) {
    _isChecked[index] = !_isChecked[index];
    notifyListeners();
  }
}
