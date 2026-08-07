import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String name;
  final double openingBalance;
  final DateTime? balanceSetAt;
  final IconData icon;
  final bool isDark;

  WalletModel({
    required this.id,
    required this.name,
    required this.openingBalance,
    this.balanceSetAt,
    required this.icon,
    this.isDark = false,
  });

  // Calculate dynamic current balance (mock property for UI binding)
  // The real logic should combine openingBalance with transaction deltas.
  double get balance => openingBalance; 

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      openingBalance: (json['opening_balance'] is num) 
          ? (json['opening_balance'] as num).toDouble() 
          : double.tryParse(json['opening_balance']?.toString() ?? '0') ?? 0.0,
      balanceSetAt: json['balance_set_at'] != null 
          ? DateTime.tryParse(json['balance_set_at'].toString()) 
          : null,
      icon: _getIconData((json['icon_code'] as num?)?.toInt() ?? 0xe041),
      isDark: json['is_dark'] ?? false,
    );
  }

  static IconData _getIconData(int codePoint) {
    if (codePoint == Icons.payments.codePoint) return Icons.payments;
    if (codePoint == Icons.account_balance.codePoint) return Icons.account_balance;
    if (codePoint == Icons.savings.codePoint) return Icons.savings;
    return Icons.account_balance_wallet;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'opening_balance': openingBalance,
      'balance_set_at': balanceSetAt?.toIso8601String(),
      'icon_code': icon.codePoint,
      'is_dark': isDark,
    };
  }
}
