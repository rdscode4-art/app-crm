class DailyReport {
  final String id;
  final String employeeName;
  final DateTime date;
  final String summary;
  final String tasksCompleted;
  final String blocks;

  DailyReport({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.summary,
    required this.tasksCompleted,
    required this.blocks,
  });

  DailyReport copyWith({
    String? id,
    String? employeeName,
    DateTime? date,
    String? summary,
    String? tasksCompleted,
    String? blocks,
  }) {
    return DailyReport(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      blocks: blocks ?? this.blocks,
    );
  }

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? json['employee_name']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      summary: json['summary']?.toString() ?? '',
      tasksCompleted: json['tasksCompleted']?.toString() ?? json['tasks_completed']?.toString() ?? '',
      blocks: json['blocks']?.toString() ?? json['blockers']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'summary': summary,
      'tasksCompleted': tasksCompleted,
      'blocks': blocks,
    };
  }
}
