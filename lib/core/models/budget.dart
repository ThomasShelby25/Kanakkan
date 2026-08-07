class BudgetModel {
  final String id;
  final String category;
  final double limitAmount;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limitAmount,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Unknown',
      limitAmount: (json['limit_amount'] is num) 
          ? (json['limit_amount'] as num).toDouble() 
          : double.tryParse(json['limit_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'limit_amount': limitAmount,
    };
  }
}
