class DailyReport {
  final String id;
  final String employeeName;
  final DateTime date;
  final String summary;
  final String tasksCompleted;
  final String blocks;
  final String status; // 'submitted', 'reviewed', 'approved'
  final String reviewNote;
  final String reviewedByName;
  final double? hoursWorked;

  DailyReport({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.summary,
    required this.tasksCompleted,
    required this.blocks,
    this.status = 'submitted',
    this.reviewNote = '',
    this.reviewedByName = '',
    this.hoursWorked,
  });

  DailyReport copyWith({
    String? id,
    String? employeeName,
    DateTime? date,
    String? summary,
    String? tasksCompleted,
    String? blocks,
    String? status,
    String? reviewNote,
    String? reviewedByName,
    double? hoursWorked,
  }) {
    return DailyReport(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      blocks: blocks ?? this.blocks,
      status: status ?? this.status,
      reviewNote: reviewNote ?? this.reviewNote,
      reviewedByName: reviewedByName ?? this.reviewedByName,
      hoursWorked: hoursWorked ?? this.hoursWorked,
    );
  }

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    // Determine the report text
    final rawReport = json['report']?.toString() ?? json['summary']?.toString() ?? '';
    
    // Attempt to parse out tasks completed and blocks if formatted
    String summary = rawReport;
    String tasksCompleted = 'None';
    String blocks = 'None';
    
    if (rawReport.contains('Tasks Completed:') && rawReport.contains('Blockers:')) {
      try {
        final summaryIndex = rawReport.indexOf('Summary:');
        final tasksIndex = rawReport.indexOf('Tasks Completed:');
        final blockersIndex = rawReport.indexOf('Blockers:');
        
        if (summaryIndex != -1 && tasksIndex != -1 && blockersIndex != -1) {
          summary = rawReport.substring(summaryIndex + 8, tasksIndex).trim();
          tasksCompleted = rawReport.substring(tasksIndex + 16, blockersIndex).trim();
          blocks = rawReport.substring(blockersIndex + 9).trim();
        }
      } catch (_) {}
    } else {
      // If it doesn't contain standard headers, maybe it contains completed / roadblocks as separate keys
      if (json['tasksCompleted'] != null || json['tasks_completed'] != null) {
        tasksCompleted = json['tasksCompleted']?.toString() ?? json['tasks_completed']?.toString() ?? 'None';
      }
      if (json['blocks'] != null || json['blockers'] != null) {
        blocks = json['blocks']?.toString() ?? json['blockers']?.toString() ?? 'None';
      }
    }

    return DailyReport(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeName: json['employee'] is Map 
          ? (json['employee']['name']?.toString() ?? '')
          : (json['employeeName']?.toString() ?? json['employee_name']?.toString() ?? ''),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      summary: summary,
      tasksCompleted: tasksCompleted,
      blocks: blocks,
      status: json['status']?.toString() ?? 'submitted',
      reviewNote: json['reviewNote']?.toString() ?? json['review_note']?.toString() ?? '',
      reviewedByName: json['reviewedBy'] is Map
          ? (json['reviewedBy']['name']?.toString() ?? '')
          : '',
      hoursWorked: json['hoursWorked'] != null ? double.tryParse(json['hoursWorked'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Generate formatted report for backend
    final formattedReport = 'Summary: $summary\nTasks Completed: $tasksCompleted\nBlockers: $blocks';
    return {
      'date': date.toIso8601String(),
      'report': formattedReport,
      'hoursWorked': hoursWorked ?? 8.0,
      'status': status,
      'reviewNote': reviewNote,
    };
  }
}
