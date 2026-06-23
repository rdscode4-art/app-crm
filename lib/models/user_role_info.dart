class UserRoleInfo {
  final String id;
  final String name;
  final String email;
  final String role;

  UserRoleInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserRoleInfo.fromJson(Map<String, dynamic> json) {
    return UserRoleInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Employee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  UserRoleInfo copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return UserRoleInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
