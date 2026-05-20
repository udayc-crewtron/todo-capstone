class Todo {
  final String todoId;
  final String title;
  final bool done;
  final int createdAt;
  final String category;
  final int? deadline; // Optional deadline timestamp

  Todo({
    required this.todoId,
    required this.title,
    required this.done,
    required this.createdAt,
    this.category = 'General',
    this.deadline,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      todoId: json['todoId'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      createdAt: json['createdAt'] as int,
      category: json['category'] as String? ?? 'General',
      deadline: json['deadline'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'todoId': todoId,
      'title': title,
      'done': done,
      'createdAt': createdAt,
      'category': category,
    };
    if (deadline != null) {
      map['deadline'] = deadline!;
    }
    return map;
  }

  // Check if todo is overdue
  bool get isOverdue {
    if (deadline == null || done) return false;
    return DateTime.now().millisecondsSinceEpoch > deadline!;
  }

  // Get time remaining in seconds
  int? get timeRemaining {
    if (deadline == null || done) return null;
    final remaining = deadline! - DateTime.now().millisecondsSinceEpoch;
    return remaining > 0 ? (remaining / 1000).round() : 0;
  }
}
