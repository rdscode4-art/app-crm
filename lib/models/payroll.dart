class CRMPayroll {
  final String id;
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  final double basicSalary;
  final double hra;
  final double transport;
  final double medical;
  final double special;
  final double otherAllowance;
  final double tax;
  final double providentFund;
  final double insurance;
  final double loan;
  final double otherDeduction;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;
  final String status;

  CRMPayroll({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.hra,
    required this.transport,
    required this.medical,
    required this.special,
    required this.otherAllowance,
    required this.tax,
    required this.providentFund,
    required this.insurance,
    required this.loan,
    required this.otherDeduction,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
  });

  factory CRMPayroll.fromJson(Map<String, dynamic> json) {
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

    final allowances = json['allowances'] as Map<String, dynamic>?;
    final deductions = json['deductions'] as Map<String, dynamic>?;

    return CRMPayroll(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: empId,
      employeeName: empName,
      month: int.tryParse(json['month']?.toString() ?? '1') ?? 1,
      year: int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      basicSalary: double.tryParse(json['basicSalary']?.toString() ?? '0') ?? 0.0,
      hra: double.tryParse(allowances?['hra']?.toString() ?? '0') ?? 0.0,
      transport: double.tryParse(allowances?['transport']?.toString() ?? '0') ?? 0.0,
      medical: double.tryParse(allowances?['medical']?.toString() ?? '0') ?? 0.0,
      special: double.tryParse(allowances?['special']?.toString() ?? '0') ?? 0.0,
      otherAllowance: double.tryParse(allowances?['other']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(deductions?['tax']?.toString() ?? '0') ?? 0.0,
      providentFund: double.tryParse(deductions?['providentFund']?.toString() ?? '0') ?? 0.0,
      insurance: double.tryParse(deductions?['insurance']?.toString() ?? '0') ?? 0.0,
      loan: double.tryParse(deductions?['loan']?.toString() ?? '0') ?? 0.0,
      otherDeduction: double.tryParse(deductions?['other']?.toString() ?? '0') ?? 0.0,
      totalEarnings: double.tryParse(json['totalEarnings']?.toString() ?? '0') ?? 0.0,
      totalDeductions: double.tryParse(json['totalDeductions']?.toString() ?? '0') ?? 0.0,
      netSalary: double.tryParse(json['netSalary']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
    );
  }
}
