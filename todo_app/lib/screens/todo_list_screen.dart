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

  @override
  void initState() {
    super.initState();
    _loadTodos();
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

  @override
  Widget build(BuildContext context) {
    final groupedTodos = _groupTodosByCategory();
    final categories = groupedTodos.keys.toList()..sort();

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
                        child: Column(
                          children: [
                            // Category Header
                            ListTile(
                              leading: Icon(categoryIcon, color: categoryColor),
                              title: Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _formatDate(todo.createdAt),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey[600]),
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
