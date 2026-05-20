class Todo {
  final String todoId;
  final String title;
  final bool done;
  final int createdAt;
  final String category;

  Todo({
    required this.todoId,
    required this.title,
    required this.done,
    required this.createdAt,
    this.category = 'General',
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      todoId: json['todoId'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      createdAt: json['createdAt'] as int,
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todoId': todoId,
      'title': title,
      'done': done,
      'createdAt': createdAt,
      'category': category,
    };
  }
}
