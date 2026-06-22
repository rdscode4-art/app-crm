class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final double? durationHours;
  final String status; // 'On Time', 'Late', 'Absent'

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.durationHours,
    required this.status,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    double? durationHours,
    String? status,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      durationHours: durationHours ?? this.durationHours,
      status: status ?? this.status,
    );
  }
}
