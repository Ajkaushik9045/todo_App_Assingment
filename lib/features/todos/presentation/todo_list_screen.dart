import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/provider/auth_provider.dart';
import '../data/todo_model.dart';
import '../provider/todo_provider.dart';
import 'add_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTodos() {
    final authProvider = context.read<AuthProvider>();
    final todoProvider = context.read<TodoProvider>();
    final userId = authProvider.user?.id;
    
    if (userId != null) {
      todoProvider.loadTodos(userId);
    }
  }

  Future<void> _refreshTodos() async {
    final authProvider = context.read<AuthProvider>();
    final todoProvider = context.read<TodoProvider>();
    final userId = authProvider.user?.id;
    
    if (userId != null) {
      await todoProvider.refreshTodos(userId);
    }
  }

  void _navigateToAddTodo([TodoModel? todoToEdit]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todoToEdit: todoToEdit),
      ),
    );
    
    if (result == true) {
      _refreshTodos();
    }
  }

  void _showDeleteConfirmation(TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = context.read<AuthProvider>();
              final todoProvider = context.read<TodoProvider>();
              final userId = authProvider.user?.id;
              
              if (userId != null) {
                final success = await todoProvider.deleteTodo(todo.id!, userId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todo deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        bottom: TabBar(
          labelColor: Colors.white,              
      unselectedLabelColor: Colors.white70, 
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading && todoProvider.todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${todoProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshTodos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodoList(todoProvider.todos, 'No todos yet'),
              _buildTodoList(todoProvider.pendingTodos, 'No pending todos'),
              _buildTodoList(todoProvider.completedTodos, 'No completed todos'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTodo(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoList(List<TodoModel> todos, String emptyMessage) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToAddTodo(),
              child: const Text('Add Your First Todo'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshTodos,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return _buildTodoCard(todo);
        },
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo) {
    final isOverdue = !todo.isCompleted && todo.deadline.isBefore(DateTime.now());
    final timeUntilDeadline = todo.deadline.difference(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToAddTodo(todo),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: todo.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: todo.isCompleted 
                            ? Colors.grey[600] 
                            : null,
                      ),
                    ),
                  ),
                  // Completion Checkbox
                  Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      return Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) async {
                          final authProvider = context.read<AuthProvider>();
                          final userId = authProvider.user?.id;
                          if (userId != null) {
                            await todoProvider.toggleTodoCompletion(todo.id!, userId);
                          }
                        },
                        activeColor: AppColors.primary,
                      );
                    },
                  ),
                  // More Options
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _navigateToAddTodo(todo);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(todo);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Description
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    decoration: todo.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Deadline and Status Row
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${todo.deadline.day}/${todo.deadline.month}/${todo.deadline.year} at ${todo.deadline.hour.toString().padLeft(2, '0')}:${todo.deadline.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(todo, isOverdue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(todo, isOverdue, timeUntilDeadline),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TodoModel todo, bool isOverdue) {
    if (todo.isCompleted) return Colors.green;
    if (isOverdue) return Colors.red;
    
    final timeUntilDeadline = todo.deadline.difference(DateTime.now());
    if (timeUntilDeadline.inHours < 24) return Colors.orange;
    return AppColors.primary;
  }

  String _getStatusText(TodoModel todo, bool isOverdue, Duration timeUntilDeadline) {
    if (todo.isCompleted) return 'COMPLETED';
    if (isOverdue) return 'OVERDUE';
    
    if (timeUntilDeadline.inDays > 0) {
      return '${timeUntilDeadline.inDays}d left';
    } else if (timeUntilDeadline.inHours > 0) {
      return '${timeUntilDeadline.inHours}h left';
    } else {
      return '${timeUntilDeadline.inMinutes}m left';
    }
  }
}