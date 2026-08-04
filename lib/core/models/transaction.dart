import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final IconData icon;
  final TransactionType type;
  final String walletName;
  final String status;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.icon,
    required this.type,
    required this.walletName,
    this.status = 'Paid',
  });
}
