import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  static const String baseUrl = 'https://kpcihwymal.execute-api.us-east-1.amazonaws.com';
  static const String userId = 'test-user';

  static Future<List<Todo>> getTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: {
          'X-User-Id': userId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> todosJson = data['todos'] ?? [];
        return todosJson.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  static Future<bool> createTodo(String title, {String category = 'General', int? deadline}) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'category': category,
      };
      if (deadline != null) {
        body['deadline'] = deadline;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {
          'X-User-Id': userId,
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating todo: $e');
      return false;
    }
  }

  static Future<bool> toggleTodo(String todoId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/todos/$todoId'),
        headers: {
          'X-User-Id': userId,
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling todo: $e');
      return false;
    }
  }

  static Future<bool> deleteTodo(String todoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$todoId'),
        headers: {
          'X-User-Id': userId,
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }
}
