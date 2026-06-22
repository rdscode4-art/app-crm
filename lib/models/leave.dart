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
}
