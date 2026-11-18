class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    final name = json['name'];
    final role = json['role'];
    if (id is! String || email is! String || name is! String || role is! String) {
      throw const FormatException('The API returned an invalid user record.');
    }
    return AuthUser(id: id, email: email, name: name, role: role);
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final user = json['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const FormatException('The API returned an invalid sign-in response.');
    }
    return AuthSession(
      token: token,
      user: AuthUser.fromJson(user),
    );
  }
}
