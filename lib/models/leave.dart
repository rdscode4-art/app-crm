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
    String empName = 'Unassigned';
    String empId = '';
    
    if (json['employee'] is Map) {
      empName = json['employee']['name']?.toString() ?? 'Unassigned';
      empId = json['employee']['_id']?.toString() ?? json['employee']['employeeId']?.toString() ?? '';
    } else {
      empName = json['employeeName']?.toString() ?? json['employee_name']?.toString() ?? 'Unassigned';
      empId = json['employeeId']?.toString() ?? json['employee_id']?.toString() ?? json['employee']?.toString() ?? '';
    }

    String rawType = (json['leaveType'] ?? json['type'] ?? 'casual').toString().toLowerCase();
    String type = 'Casual';
    if (rawType == 'sick') {
      type = 'Sick';
    } else if (rawType == 'annual') {
      type = 'Annual';
    }

    String rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();
    String status = 'Pending';
    if (rawStatus == 'approved') {
      status = 'Approved';
    } else if (rawStatus == 'rejected') {
      status = 'Rejected';
    }

    return Leave(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      type: type,
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
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    final difference = endDate.difference(startDate).inDays;
    final calculatedDays = difference >= 0 ? difference + 1 : 1;

    return {
      'employee': employeeId,
      'leaveType': type.toLowerCase(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'days': calculatedDays,
      'reason': reason,
      'status': status.toLowerCase(),
    };
  }
}
