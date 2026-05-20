class Todo {
  final String todoId;
  final String title;
  final bool done;
  final int createdAt;

  Todo({
    required this.todoId,
    required this.title,
    required this.done,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      todoId: json['todoId'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      createdAt: json['createdAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todoId': todoId,
      'title': title,
      'done': done,
      'createdAt': createdAt,
    };
  }
}
