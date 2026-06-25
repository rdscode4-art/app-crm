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

  factory Employee.fromJson(Map<String, dynamic> json) {
    String rawStatus = json['status'] ?? 'Active';
    String capitalizedStatus = rawStatus.isNotEmpty 
        ? rawStatus[0].toUpperCase() + rawStatus.substring(1).toLowerCase() 
        : 'Active';

    String roleName = 'employee';
    if (json['role'] != null) {
      if (json['role'] is Map) {
        roleName = json['role']['name'] ?? 'employee';
      } else {
        roleName = json['role'].toString();
      }
    }

    return Employee(
      id: json['employeeId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: roleName,
      department: json['department'] ?? 'General',
      status: capitalizedStatus,
      salary: (json['salary'] ?? 0.0).toDouble(),
      performanceRating: (json['performanceRating'] ?? 5.0).toDouble(),
      dateJoined: json['joiningDate'] ?? json['createdAt'] ?? DateTime.now().toString(),
      phone: json['phone'] ?? '',
      avatarUrl: json['profileImage'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
  }
}
