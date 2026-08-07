import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';

class ReportService {
  static Future<void> generateAndPrintTransactionReport({
    required String userName,
    required double netBalance,
    required double totalIncome,
    required double totalExpense,
    required List<TransactionModel> transactions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(userName),
            pw.SizedBox(height: 20),
            _buildSummary(netBalance, totalIncome, totalExpense),
            pw.SizedBox(height: 30),
            _buildTransactionTable(transactions),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kanakkan_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildHeader(String userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('KANAKKAN', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
        pw.SizedBox(height: 4),
        pw.Text('Official Account Statement', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.SizedBox(height: 16),
        pw.Text('Account Holder: $userName', style: pw.TextStyle(fontSize: 12)),
        pw.Text('Generated On: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 12)),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildSummary(double netBalance, double income, double expense) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryBox('Net Balance', netBalance, PdfColors.black),
        _summaryBox('Total Income', income, PdfColors.green700),
        _summaryBox('Total Expense', expense, PdfColors.red700),
      ],
    );
  }

  static pw.Widget _summaryBox(String title, double amount, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text('Rs. ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return pw.Text('No transactions found in this period.', style: const pw.TextStyle(fontSize: 12));
    }

    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Description', 'Category', 'Wallet', 'Type', 'Amount'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      data: transactions.map((tx) {
        return [
          tx.date.toString().split(' ')[0],
          tx.title,
          tx.category,
          tx.walletName,
          tx.type == TransactionType.income ? 'INCOME' : 'EXPENSE',
          '${tx.type == TransactionType.income ? '+' : '-'}Rs.${tx.amount.toStringAsFixed(2)}',
        ];
      }).toList(),
    );
  }
}
