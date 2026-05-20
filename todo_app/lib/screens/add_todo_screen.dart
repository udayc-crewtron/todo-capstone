import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String _selectedCategory = 'General';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'General', 'icon': Icons.task_alt, 'color': Colors.grey},
    {'name': 'Vacation', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
    {'name': 'Life Goals', 'icon': Icons.flag, 'color': Colors.purple},
    {'name': 'Work', 'icon': Icons.work, 'color': Colors.blue},
    {'name': 'Shopping', 'icon': Icons.shopping_cart, 'color': Colors.green},
    {'name': 'Health', 'icon': Icons.fitness_center, 'color': Colors.red},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final title = _controller.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a todo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.createTodo(title, category: _selectedCategory);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add todo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'What needs to be done?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              autofocus: true,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _addTodo(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['name'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : category['color'],
                      ),
                      const SizedBox(width: 6),
                      Text(category['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: category['color'] as Color,
                  backgroundColor: (category['color'] as Color).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addTodo,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_isLoading ? 'Adding...' : 'Add Todo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _categories.firstWhere(
                  (c) => c['name'] == _selectedCategory,
                )['color'] as Color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
