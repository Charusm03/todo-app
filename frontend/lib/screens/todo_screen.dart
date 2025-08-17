import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/todo.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/todo_item.dart';
import 'login_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _authService = AuthService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  User? _currentUser;
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        await _loadTodos();
      } else {
        _handleLogout();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodos() async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final todos = await ApiService.getTodos(token);
        setState(() {
          _todos = todos;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load todos';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTodo() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title');
      return;
    }

    try {
      final token = await _authService.getToken();
      if (token != null) {
        await ApiService.createTodo(
          token,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );

        _titleController.clear();
        _descriptionController.clear();
        Navigator.of(context).pop();
        _showSnackBar('Todo created successfully');
        _loadTodos();
      }
    } catch (e) {
      _showSnackBar(
          'Failed to create todo: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> _updateTodo(Todo todo, String title, String description) async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        await ApiService.updateTodo(
          token,
          todo.id,
          title,
          description,
          todo.completed,
        );

        _showSnackBar('Todo updated successfully');
        _loadTodos();
      }
    } catch (e) {
      _showSnackBar(
          'Failed to update todo: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        await ApiService.toggleTodo(token, todo.id);
        _loadTodos();
      }
    } catch (e) {
      _showSnackBar(
          'Failed to toggle todo: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        await ApiService.deleteTodo(token, todo.id);
        _showSnackBar('Todo deleted successfully');
        _loadTodos();
      }
    } catch (e) {
      _showSnackBar(
          'Failed to delete todo: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCreateTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter todo title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createTodo,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTodoDialog(Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter todo title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateTodo(
              todo,
              _titleController.text.trim(),
              _descriptionController.text.trim(),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                _currentUser?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              if (value == 1) {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                enabled: false, // info only
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.username ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Role: ${_currentUser?.role?.toUpperCase() ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadTodos();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No todos yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentUser?.canCreate() == true
                                ? 'Tap the + button to create your first todo'
                                : 'Ask an admin to create todos',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTodos,
                      child: ListView.builder(
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return TodoItem(
                            todo: todo,
                            currentUser: _currentUser!,
                            onToggle: () => _toggleTodo(todo),
                            onEdit: () => _showEditTodoDialog(todo),
                            onDelete: () => _deleteTodo(todo),
                          );
                        },
                      ),
                    ),
      floatingActionButton: _currentUser?.canCreate() == true
          ? FloatingActionButton(
              onPressed: _showCreateTodoDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
