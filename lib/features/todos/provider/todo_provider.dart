import 'package:flutter/material.dart';
import '../data/todo_model.dart';
import '../data/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();
  
  List<TodoModel> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get completed todos
  List<TodoModel> get completedTodos => 
      _todos.where((todo) => todo.isCompleted).toList();

  // Get pending todos
  List<TodoModel> get pendingTodos => 
      _todos.where((todo) => !todo.isCompleted).toList();

  // Get overdue todos
  List<TodoModel> get overdueTodos => _todos
      .where((todo) => !todo.isCompleted && todo.deadline.isBefore(DateTime.now()))
      .toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load all todos for a user
  Future<void> loadTodos(String userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      _todos = await _repository.getTodos(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new todo
  Future<bool> createTodo(TodoModel todo) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final newTodo = await _repository.createTodo(todo);
      _todos.insert(0, newTodo);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing todo
  Future<bool> updateTodo(TodoModel todo) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final updatedTodo = await _repository.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a todo
  Future<bool> deleteTodo(String todoId, String userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.deleteTodo(todoId, userId);
      _todos.removeWhere((todo) => todo.id == todoId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle todo completion
  Future<bool> toggleTodoCompletion(String todoId, String userId) async {
    _setError(null);
    
    try {
      final updatedTodo = await _repository.toggleTodoCompletion(todoId, userId);
      final index = _todos.indexWhere((t) => t.id == todoId);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Refresh todos
  Future<void> refreshTodos(String userId) async {
    await loadTodos(userId);
  }
}