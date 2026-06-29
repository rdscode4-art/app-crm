class Employee {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String role;
  final String? designation;
  final String department;
  final String status; // 'Active' or 'Inactive'
  final double salary;
  final double performanceRating; // e.g. 4.5
  final String dateJoined;
  final String phone;
  final String avatarUrl;
  final String? password;

  Employee({
    required this.id,
    String? employeeId,
    required this.name,
    required this.email,
    required this.role,
    this.designation,
    required this.department,
    required this.status,
    required this.salary,
    required this.performanceRating,
    required this.dateJoined,
    required this.phone,
    required this.avatarUrl,
    this.password,
  }) : employeeId = employeeId ?? id;

  Employee copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
    String? role,
    String? designation,
    String? department,
    String? status,
    double? salary,
    double? performanceRating,
    String? dateJoined,
    String? phone,
    String? avatarUrl,
    String? password,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      status: status ?? this.status,
      salary: salary ?? this.salary,
      performanceRating: performanceRating ?? this.performanceRating,
      dateJoined: dateJoined ?? this.dateJoined,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      password: password ?? this.password,
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

    String? designationName;
    if (json['designation'] != null && json['designation'].toString().isNotEmpty) {
      String rawDesignation = json['designation'].toString();
      designationName = rawDesignation.split(' ').map((word) {
        if (word.isEmpty) return '';
        if (word.toUpperCase() == 'MD' || word.toUpperCase() == 'HO' || word.toUpperCase() == 'HR') {
          return word.toUpperCase();
        }
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    String parsedDate = '';
    if (json['joiningDate'] != null) {
      try {
        parsedDate = DateTime.parse(json['joiningDate'].toString()).toLocal().toString().split(' ')[0];
      } catch (_) {
        parsedDate = json['joiningDate'].toString();
      }
    } else if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString()).toLocal().toString().split(' ')[0];
      } catch (_) {
        parsedDate = json['createdAt'].toString();
      }
    } else {
      parsedDate = DateTime.now().toString().split(' ')[0];
    }

    return Employee(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['employeeId']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: roleName,
      designation: designationName,
      department: json['department'] ?? 'General',
      status: capitalizedStatus,
      salary: (json['salary'] ?? 0.0).toDouble(),
      performanceRating: (json['performanceRating'] ?? 5.0).toDouble(),
      dateJoined: parsedDate,
      phone: json['phone'] ?? '',
      avatarUrl: json['profileImage'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
  }
}
