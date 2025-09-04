import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import 'todo_model.dart';

class TodoRepository {
  final SupabaseClient _client = SupabaseService.client;
  static const String _tableName = 'todos';

  // Create a new todo
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(todo.toJson())
          .select()
          .single();
      
      return TodoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create todo: $e');
    }
  }

  // Get all todos for a user
  Future<List<TodoModel>> getTodos(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<TodoModel>((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  // Get a single todo by ID
  Future<TodoModel?> getTodoById(String todoId, String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', todoId)
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null ? TodoModel.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch todo: $e');
    }
  }

  // Update a todo
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(todo.toJson())
          .eq('id', todo.id!)
          .eq('user_id', todo.userId)
          .select()
          .single();
      
      return TodoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String todoId, String userId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', todoId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  // Toggle todo completion status
  Future<TodoModel> toggleTodoCompletion(String todoId, String userId) async {
    try {
      // First get the current todo
      final currentTodo = await getTodoById(todoId, userId);
      if (currentTodo == null) {
        throw Exception('Todo not found');
      }

      // Toggle the completion status
      final updatedTodo = currentTodo.copyWith(
        isCompleted: !currentTodo.isCompleted,
      );

      return await updateTodo(updatedTodo);
    } catch (e) {
      throw Exception('Failed to toggle todo completion: $e');
    }
  }

  // Get todos by completion status
  Future<List<TodoModel>> getTodosByStatus(String userId, bool isCompleted) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', isCompleted)
          .order('created_at', ascending: false);
      
      return response.map<TodoModel>((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch todos by status: $e');
    }
  }

  // Get overdue todos
  Future<List<TodoModel>> getOverdueTodos(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .lt('deadline', now)
          .order('deadline', ascending: true);
      
      return response.map<TodoModel>((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch overdue todos: $e');
    }
  }
}