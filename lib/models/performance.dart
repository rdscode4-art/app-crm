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
}
