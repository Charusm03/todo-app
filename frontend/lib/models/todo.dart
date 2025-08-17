class Todo {
  final int id;
  final String title;
  final String description;
  final bool completed;
  final int userId;
  final String? username;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.userId,
    this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] == 1 || json['completed'] == true,
      userId: json['user_id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'user_id': userId,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    int? userId,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
