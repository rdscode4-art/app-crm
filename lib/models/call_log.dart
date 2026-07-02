class CallLog {
  final String id;
  final String leadId;
  final String leadName;
  final String employeeId;
  final String employeeName;
  final int durationMinutes;
  final String outcome; // e.g., 'Connected', 'Voicemail', 'Busy', 'No Answer'
  final String notes;
  final DateTime timestamp;

  CallLog({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.employeeId,
    required this.employeeName,
    required this.durationMinutes,
    required this.outcome,
    this.notes = '',
    required this.timestamp,
  });

  CallLog copyWith({
    String? id,
    String? leadId,
    String? leadName,
    String? employeeId,
    String? employeeName,
    int? durationMinutes,
    String? outcome,
    String? notes,
    DateTime? timestamp,
  }) {
    return CallLog(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      leadId: json['leadId']?.toString() ?? '',
      leadName: json['leadName']?.toString() ?? 'Unknown Lead',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? 'Unknown Agent',
      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '0') ?? 0,
      outcome: json['outcome']?.toString() ?? 'No Answer',
      notes: json['notes']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'leadName': leadName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'durationMinutes': durationMinutes,
      'outcome': outcome,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
