import 'dart:async';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import 'add_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];
  bool isLoading = true;
  Map<String, bool> expandedCategories = {};
  Timer? _timer;
  Set<String> _shownAlerts = {}; // Track shown alerts

  @override
  void initState() {
    super.initState();
    _loadTodos();
    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _checkOverdueTodos();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkOverdueTodos() {
    for (var todo in todos) {
      if (todo.isOverdue && !_shownAlerts.contains(todo.todoId)) {
        _shownAlerts.add(todo.todoId);
        _showMissedAlert(todo);
      }
    }
  }

  void _showMissedAlert(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
            const SizedBox(width: 12),
            const Text(
              'You Missed Again!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '"${todo.title}" deadline has passed!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTodos() async {
    setState(() => isLoading = true);
    final fetchedTodos = await ApiService.getTodos();
    setState(() {
      todos = fetchedTodos;
      isLoading = false;
      // Initialize all categories as expanded
      for (var todo in todos) {
        expandedCategories[todo.category] = true;
      }
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    final success = await ApiService.toggleTodo(todo.todoId);
    if (success) {
      _loadTodos();
    } else {
      _showError('Failed to toggle todo');
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final success = await ApiService.deleteTodo(todo.todoId);
    if (success) {
      _shownAlerts.remove(todo.todoId); // Remove from shown alerts
      _loadTodos();
    } else {
      _showError('Failed to delete todo');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Map<String, List<Todo>> _groupTodosByCategory() {
    final Map<String, List<Todo>> grouped = {};
    for (var todo in todos) {
      final category = todo.category;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(todo);
    }
    return grouped;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'very important':
        return Icons.priority_high;
      case 'vacation':
        return Icons.flight_takeoff;
      case 'life goals':
        return Icons.flag;
      case 'work':
        return Icons.work;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.fitness_center;
      default:
        return Icons.task_alt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'very important':
        return Colors.red[700]!;
      case 'vacation':
        return Colors.orange;
      case 'life goals':
        return Colors.purple;
      case 'work':
        return Colors.blue;
      case 'shopping':
        return Colors.green;
      case 'health':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCountdown(int seconds) {
    if (seconds <= 0) return 'OVERDUE!';

    final duration = Duration(seconds: seconds);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTodos = _groupTodosByCategory();
    final categories = groupedTodos.keys.toList()..sort((a, b) {
      // Very Important always first
      if (a.toLowerCase() == 'very important') return -1;
      if (b.toLowerCase() == 'very important') return 1;
      return a.compareTo(b);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No todos yet!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first todo',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTodos,
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryTodos = groupedTodos[category]!;
                      final isExpanded = expandedCategories[category] ?? true;
                      final categoryIcon = _getCategoryIcon(category);
                      final categoryColor = _getCategoryColor(category);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        elevation: category.toLowerCase() == 'very important' ? 4 : 1,
                        child: Column(
                          children: [
                            // Category Header
                            ListTile(
                              leading: Icon(categoryIcon, color: categoryColor, size: 28),
                              title: Text(
                                category,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: category.toLowerCase() == 'very important' ? 18 : 16,
                                  color: category.toLowerCase() == 'very important'
                                    ? Colors.red[700]
                                    : null,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${categoryTodos.length}',
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        expandedCategories[category] =
                                            !isExpanded;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              tileColor: categoryColor.withOpacity(0.05),
                            ),
                            // Category Items
                            if (isExpanded)
                              ...categoryTodos.map((todo) {
                                final hasDeadline = todo.deadline != null;
                                final timeLeft = todo.timeRemaining;
                                final isOverdue = todo.isOverdue;

                                return Dismissible(
                                  key: Key(todo.todoId),
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _deleteTodo(todo),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: todo.done,
                                      onChanged: (_) => _toggleTodo(todo),
                                    ),
                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                        decoration: todo.done
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: todo.done
                                            ? Colors.grey
                                            : isOverdue
                                                ? Colors.red[700]
                                                : Colors.black,
                                        fontWeight: isOverdue
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(todo.createdAt),
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        if (hasDeadline && timeLeft != null && !todo.done)
                                          Container(
                                            margin: const EdgeInsets.only(top: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isOverdue
                                                  ? Colors.red[100]
                                                  : timeLeft < 3600
                                                      ? Colors.orange[100]
                                                      : Colors.blue[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isOverdue
                                                      ? Icons.error
                                                      : Icons.timer,
                                                  size: 16,
                                                  color: isOverdue
                                                      ? Colors.red[700]
                                                      : timeLeft < 3600
                                                          ? Colors.orange[700]
                                                          : Colors.blue[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatCountdown(timeLeft),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isOverdue
                                                        ? Colors.red[700]
                                                        : timeLeft < 3600
                                                            ? Colors.orange[700]
                                                            : Colors.blue[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
          if (result == true) {
            _loadTodos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
