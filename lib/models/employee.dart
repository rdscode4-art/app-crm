class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status; // 'Active' or 'Inactive'
  final double salary;
  final double performanceRating; // e.g. 4.5
  final String dateJoined;
  final String phone;
  final String avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    required this.salary,
    required this.performanceRating,
    required this.dateJoined,
    required this.phone,
    required this.avatarUrl,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? department,
    String? status,
    double? salary,
    double? performanceRating,
    String? dateJoined,
    String? phone,
    String? avatarUrl,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      status: status ?? this.status,
      salary: salary ?? this.salary,
      performanceRating: performanceRating ?? this.performanceRating,
      dateJoined: dateJoined ?? this.dateJoined,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
