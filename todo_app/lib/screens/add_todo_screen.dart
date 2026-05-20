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
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedTime;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Very Important', 'icon': Icons.priority_high, 'color': Colors.red[700]},
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

  Future<void> _pickDateTime() async {
    // Pick date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    // Pick time
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time == null) return;

      setState(() {
        _selectedDeadline = date;
        _selectedTime = time;
      });
    }
  }

  void _clearDeadline() {
    setState(() {
      _selectedDeadline = null;
      _selectedTime = null;
    });
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDeadline == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDeadline!.year,
      _selectedDeadline!.month,
      _selectedDeadline!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
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

    // Very Important category requires deadline
    if (_selectedCategory == 'Very Important' && _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Very Important todos require a deadline!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final deadline = _getCombinedDateTime()?.millisecondsSinceEpoch;
    final success = await ApiService.createTodo(
      title,
      category: _selectedCategory,
      deadline: deadline,
    );

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
    final combinedDateTime = _getCombinedDateTime();

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
            // Deadline section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline ${_selectedCategory == 'Very Important' ? '(Required)' : '(Optional)'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedCategory == 'Very Important'
                        ? Colors.red[700]
                        : null,
                  ),
                ),
                if (combinedDateTime != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearDeadline,
                    tooltip: 'Clear deadline',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: Icon(
                combinedDateTime != null ? Icons.edit_calendar : Icons.calendar_today,
                color: _selectedCategory == 'Very Important'
                    ? Colors.red[700]
                    : Colors.blue,
              ),
              label: Text(
                combinedDateTime != null
                    ? '${combinedDateTime.day}/${combinedDateTime.month}/${combinedDateTime.year} at ${combinedDateTime.hour}:${combinedDateTime.minute.toString().padLeft(2, '0')}'
                    : 'Set Deadline',
                style: TextStyle(
                  color: _selectedCategory == 'Very Important'
                      ? Colors.red[700]
                      : Colors.blue,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(
                  color: _selectedCategory == 'Very Important'
                      ? Colors.red[700]!
                      : Colors.blue,
                  width: combinedDateTime != null ? 2 : 1,
                ),
              ),
            ),
            if (_selectedCategory == 'Very Important' && combinedDateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'ll get "You Missed Again!" alert if deadline passes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
