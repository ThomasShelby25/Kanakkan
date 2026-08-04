class SalaryEntryModel {
  final String id;
  final String period; // e.g. "OCT 2023"
  final double grossSalary;
  final double incomeTax;
  final double retirement401k;
  final double netCredited;
  final DateTime nextPayDate;

  SalaryEntryModel({
    required this.id,
    required this.period,
    required this.grossSalary,
    required this.incomeTax,
    required this.retirement401k,
    required this.netCredited,
    required this.nextPayDate,
  });
}
