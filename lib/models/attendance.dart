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

  factory Attendance.fromJson(Map<String, dynamic> json) {
    String empId = '';
    String empName = 'Employee';
    if (json['employee'] != null) {
      if (json['employee'] is Map) {
        empId = json['employee']['_id']?.toString() ?? '';
        empName = json['employee']['name']?.toString() ?? 'Employee';
      } else {
        empId = json['employee'].toString();
      }
    }

    final parsedDate = json['date'] != null
        ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
        : DateTime.now();

    String inTime = '--:--';
    if (json['checkIn'] != null) {
      final dt = DateTime.tryParse(json['checkIn'].toString())?.toLocal();
      if (dt != null) {
        inTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
    }

    String? outTime;
    if (json['checkOut'] != null) {
      final dt = DateTime.tryParse(json['checkOut'].toString())?.toLocal();
      if (dt != null) {
        outTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
    }

    final workH = double.tryParse(json['workHours']?.toString() ?? '') ?? double.tryParse(json['durationHours']?.toString() ?? '');

    String uiStatus = 'Absent';
    final backendStatus = json['status']?.toString().toLowerCase() ?? 'absent';
    if (backendStatus == 'present' || backendStatus == 'on time') {
      uiStatus = 'Present';
    } else if (backendStatus == 'late') {
      uiStatus = 'Late';
    } else if (backendStatus == 'absent') {
      uiStatus = 'Absent';
    } else {
      uiStatus = backendStatus.isNotEmpty
          ? '${backendStatus[0].toUpperCase()}${backendStatus.substring(1)}'
          : backendStatus;
    }

    return Attendance(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      date: parsedDate,
      checkInTime: inTime,
      checkOutTime: outTime,
      durationHours: workH,
      status: uiStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employeeId,
      'date': date.toIso8601String(),
      'status': status == 'On Time' || status == 'Present' ? 'present' : (status == 'Late' ? 'late' : 'absent'),
      'workHours': durationHours,
    };
  }
}
