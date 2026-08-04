import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final bool isDark;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    this.isDark = false,
  });
}
