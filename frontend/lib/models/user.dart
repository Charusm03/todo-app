class User {
  final int id;
  final String username;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  // Role-based permission methods
  bool canCreate() {
    return role == 'admin' || role == 'manager';
  }

  bool canEdit() {
    return role == 'admin' || role == 'manager';
  }

  bool canDelete() {
    return role == 'admin';
  }

  bool canToggle() {
    return true; // All users can toggle their own todos
  }

  bool isAdmin() {
    return role == 'admin';
  }

  bool isManager() {
    return role == 'manager';
  }

  bool isEmployee() {
    return role == 'employee';
  }

  String get displayRole {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'employee':
        return 'Employee';
      default:
        return role.toUpperCase();
    }
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode ^ role.hashCode;
  }
}
