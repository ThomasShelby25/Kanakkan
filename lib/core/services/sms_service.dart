import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';
import '../models/transaction.dart';
import 'dart:convert';

// Top-level function for background SMS processing
@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  final parsed = SmsService.parseSms(message.body ?? "");
  if (parsed != null) {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('sms_transaction_queue') ?? [];
    
    final transactionMap = {
      'title': parsed['title'],
      'amount': parsed['amount'],
      'type': parsed['type'],
      'date': DateTime.now().toIso8601String(),
    };
    
    queue.add(jsonEncode(transactionMap));
    await prefs.setStringList('sms_transaction_queue', queue);
  }
}

class SmsService {
  static final Telephony telephony = Telephony.instance;

  static Future<void> initialize() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted == true) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _handleMessage(message);
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }

  static void _handleMessage(SmsMessage message) {
    simulateSms(message.body ?? "");
  }

  static Future<void> simulateSms(String body) async {
    final parsed = parseSms(body);
    if (parsed != null) {
      final isExpense = parsed['type'] == 'expense';
      await SupabaseService.createTransaction(
        TransactionModel(
          id: '',
          title: parsed['title'],
          amount: parsed['amount'],
          type: isExpense ? TransactionType.expense : TransactionType.income,
          date: DateTime.now(),
          category: parsed['category'] ?? 'Auto SMS',
          icon: isExpense ? Icons.shopping_bag : Icons.work,
          walletName: parsed['account'] ?? 'Main',
        ),
      );
    }
  }

  static Map<String, dynamic>? parseSms(String body) {
    final lowerBody = body.toLowerCase();
    
    // Expense keywords (Dr. = Debit in banking)
    bool isExpense = lowerBody.contains('debited') ||
        lowerBody.contains('debit') ||
        lowerBody.contains(' dr.') ||
        lowerBody.contains('dr. ') ||
        lowerBody.contains('spent') ||
        lowerBody.contains('paid') ||
        lowerBody.contains('payment of') ||
        lowerBody.contains('withdrawn') ||
        lowerBody.contains('purchase');

    // Income keywords (Cr. = Credit in banking)
    bool isIncome = lowerBody.contains('credited') ||
        lowerBody.contains('credit') ||
        lowerBody.contains(' cr.') ||
        lowerBody.contains('cr. ') ||
        lowerBody.contains('received') ||
        lowerBody.contains('deposited') ||
        lowerBody.contains('refund');
    
    if (!isExpense && !isIncome) return null;
    
    // --- Amount extraction ---
    // Supports: ₹500, Rs.500, Rs 500, INR 500.00
    final amountRegex = RegExp(
      r'(?:(?:rs\.?|inr|₹)\s*([\d,]+\.?\d*))|([\d,]+\.?\d*)\s*(?:rs\.?|inr|₹)',
      caseSensitive: false,
    );
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    String amountStr = (amountMatch.group(1) ?? amountMatch.group(2) ?? '0').replaceAll(',', '');
    double amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) return null;

    // --- Payee / Sender extraction ---
    // Canara: "to GUHAN;" | "from GUHAN;"
    // HDFC: "to VPA abc@upi" | "Info: Swiggy"
    String? payee;
    final toMatch = RegExp(r'\bto\s+([A-Z][A-Za-z0-9 @._-]{1,30}?)(?:\s*[;,.]|\s+UPI|\s+on\b|\s+Ref|\s*$)', caseSensitive: false).firstMatch(body);
    final fromMatch = RegExp(r'\bfrom\s+([A-Z][A-Za-z0-9 @._-]{1,30}?)(?:\s*[;,.]|\s+UPI|\s+Ref|\s*$)', caseSensitive: false).firstMatch(body);
    final infoMatch = RegExp(r'Info:\s*([A-Za-z0-9 _-]+)', caseSensitive: false).firstMatch(body);
    final vpaMatch = RegExp(r'VPA\s+([\w@.]+)', caseSensitive: false).firstMatch(body);

    if (isExpense) {
      payee = toMatch?.group(1)?.trim() ?? infoMatch?.group(1)?.trim() ?? vpaMatch?.group(1)?.trim();
    } else {
      payee = fromMatch?.group(1)?.trim() ?? infoMatch?.group(1)?.trim() ?? vpaMatch?.group(1)?.trim();
    }

    // --- Account extraction ---
    // Canara: "Acct XXX300" | HDFC: "a/c XXXXXX"
    String? account;
    final acctMatch = RegExp(r'(?:acct?|a\/c)\s*([X\d*]+\d{2,4})', caseSensitive: false).firstMatch(body);
    account = acctMatch?.group(1)?.trim();

    // --- Build title ---
    String title;
    if (payee != null && payee.isNotEmpty) {
      title = isExpense ? 'Paid to $payee' : 'Received from $payee';
    } else {
      title = isExpense ? 'Bank Debit' : 'Bank Credit';
    }

    // --- Category based on payee ---
    String category = _guessCategory(payee ?? '');

    return {
      'title': title,
      'amount': amount,
      'type': isExpense ? 'expense' : 'income',
      'category': category,
      'account': account ?? 'Unknown',
      'payee': payee ?? '',
    };
  }

  /// Guess a category based on payee/merchant name
  static String _guessCategory(String payee) {
    final p = payee.toLowerCase();
    if (p.contains('swiggy') || p.contains('zomato') || p.contains('food')) return 'Food';
    if (p.contains('uber') || p.contains('ola') || p.contains('rapido')) return 'Transport';
    if (p.contains('amazon') || p.contains('flipkart') || p.contains('myntra')) return 'Shopping';
    if (p.contains('netflix') || p.contains('spotify') || p.contains('hotstar')) return 'Entertainment';
    if (p.contains('electricity') || p.contains('water') || p.contains('gas')) return 'Bills';
    if (p.contains('hospital') || p.contains('pharmacy') || p.contains('doctor')) return 'Health';
    return 'Auto SMS';
  }

  
  static Future<void> syncBackgroundQueue() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('sms_transaction_queue') ?? [];
    
    if (queue.isEmpty) return;
    
    for (String item in queue) {
      try {
        final Map<String, dynamic> data = jsonDecode(item);
        if (SupabaseService.currentUser?.id != null) {
          await SupabaseService.createTransaction(
            TransactionModel(
              id: '',
              title: data['title'],
              amount: data['amount'],
              type: data['type'] == 'expense' ? TransactionType.expense : TransactionType.income,
              date: DateTime.parse(data['date']),
              category: 'Auto SMS',
              icon: data['type'] == 'expense' ? Icons.shopping_bag : Icons.work,
              walletName: 'Main',
            ),
          );
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    await prefs.setStringList('sms_transaction_queue', []);
  }

  /// Scans the phone's SMS inbox for bank transactions.
  /// Reads the last 30 days of messages, filters using parseSms,
  /// and inserts only new ones (not already tracked) into Supabase.
  static Future<int> scanInboxForTransactions() async {
    int newCount = 0;
    try {
      // Get SMS permission first
      bool? granted = await telephony.requestPhoneAndSmsPermissions;
      if (granted != true) return 0;

      // Calculate timestamp for 30 days ago
      final since = DateTime.now().subtract(const Duration(days: 30));
      final sinceMs = since.millisecondsSinceEpoch;

      // Read inbox — filter by date
      final messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE).greaterThanOrEqualTo(sinceMs.toString()),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      if (messages.isEmpty) return 0;

      // Get the last-scanned timestamp to avoid duplicates
      final prefs = await SharedPreferences.getInstance();
      final lastScanned = prefs.getInt('last_sms_scan_ts') ?? 0;
      int latestTs = lastScanned;

      for (final sms in messages) {
        final body = sms.body ?? '';
        final smsTs = int.tryParse(sms.date?.toString() ?? '0') ?? 0;

        // Skip already-processed messages
        if (smsTs <= lastScanned) continue;

        if (smsTs > latestTs) latestTs = smsTs;

        final parsed = parseSms(body);
        if (parsed == null) continue;

        final date = DateTime.fromMillisecondsSinceEpoch(smsTs);

        final isExpense = parsed['type'] == 'expense';
        await SupabaseService.createTransaction(
          TransactionModel(
            id: '',
            title: parsed['title'],
            amount: parsed['amount'],
            type: isExpense ? TransactionType.expense : TransactionType.income,
            date: date,
            category: parsed['category'] ?? 'Auto SMS',
            icon: isExpense ? Icons.shopping_bag : Icons.work,
            walletName: parsed['account'] ?? 'Main',
          ),
        );
        newCount++;
      }

      // Save the latest timestamp so we don't re-process next time
      if (latestTs > lastScanned) {
        await prefs.setInt('last_sms_scan_ts', latestTs);
      }
    } catch (e) {
      debugPrint('SMS inbox scan error: $e');
    }
    return newCount;
  }
}
