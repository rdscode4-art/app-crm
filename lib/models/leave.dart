class Leave {
  final String id;
  final String employeeId;
  final String employeeName;
  final String type; // 'Casual', 'Sick', 'Annual'
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  Leave copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? status,
  }) {
    return Leave(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? json['employee_id']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? json['employee_name']?.toString() ?? '',
      type: json['type']?.toString() ?? json['leave_type']?.toString() ?? 'Casual',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : json['start_date'] != null
              ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
              : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : json['end_date'] != null
              ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
              : DateTime.now(),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
    };
  }
}
