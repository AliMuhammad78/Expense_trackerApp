class User {
  final int? id;
  final String username;
  final String email;
  final String password;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  // Convert a User object into a Map for SQFlite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Only include ID if it exists (for updates)
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // Convert a Map from SQFlite back into a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?, // Explicit casting for safety
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}