class Performance {
  final String id;
  final String employeeId;
  final String employeeName;
  final String period; // e.g., 'Q1 2026'
  final double kpiScore; // 0 to 100
  final String managerFeedback;
  final int ratingStars; // 1 to 5

  Performance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.period,
    required this.kpiScore,
    required this.managerFeedback,
    required this.ratingStars,
  });

  Performance copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? period,
    double? kpiScore,
    String? managerFeedback,
    int? ratingStars,
  }) {
    return Performance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      period: period ?? this.period,
      kpiScore: kpiScore ?? this.kpiScore,
      managerFeedback: managerFeedback ?? this.managerFeedback,
      ratingStars: ratingStars ?? this.ratingStars,
    );
  }

  factory Performance.fromJson(Map<String, dynamic> json) {
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

    String periodStr = 'Q1 2026';
    if (json['reviewPeriod'] != null && json['reviewPeriod']['startDate'] != null) {
      final start = DateTime.tryParse(json['reviewPeriod']['startDate'].toString());
      if (start != null) {
        final quarter = ((start.month - 1) / 3).floor() + 1;
        periodStr = 'Q$quarter ${start.year}';
      }
    } else if (json['reviewDate'] != null) {
      final date = DateTime.tryParse(json['reviewDate'].toString());
      if (date != null) {
        final quarter = ((date.month - 1) / 3).floor() + 1;
        periodStr = 'Q$quarter ${date.year}';
      }
    }

    double overall = double.tryParse(json['overallRating']?.toString() ?? '0.0') ?? 0.0;
    if (overall == 0.0 && json['ratings'] != null) {
      try {
        final ratingsMap = json['ratings'] as Map<String, dynamic>;
        double sum = 0.0;
        int count = 0;
        ratingsMap.forEach((key, value) {
          final val = double.tryParse(value.toString());
          if (val != null) {
            sum += val;
            count++;
          }
        });
        if (count > 0) {
          overall = sum / count;
        }
      } catch (_) {}
    }

    final double kpi = overall * 20.0;
    final int stars = overall.round().clamp(1, 5);

    return Performance(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      period: periodStr,
      kpiScore: kpi,
      managerFeedback: json['comments']?.toString() ?? json['employeeFeedback']?.toString() ?? '',
      ratingStars: stars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employeeId,
      'reviewPeriod': {
        'startDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'endDate': DateTime.now().toIso8601String(),
      },
      'ratings': {
        'qualityOfWork': ratingStars,
        'productivity': ratingStars,
        'communication': ratingStars,
        'teamwork': ratingStars,
        'punctuality': ratingStars,
        'initiative': ratingStars,
      },
      'comments': managerFeedback,
      'status': 'submitted',
    };
  }
}
