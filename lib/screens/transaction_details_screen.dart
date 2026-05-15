import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker_001/models/transaction.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';
import 'package:money_tracker_001/theme.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Details', style: TextStyle(color: kBlack, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Icon and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.pink.shade100, // Matches your Image 1
                      child: Icon(transaction.categoryIcon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      transaction.categoryName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Type
                _DetailRow(label: 'Type', value: isExpense ? 'Expense' : 'Income'),
                const Divider(height: 40),

                // Amount
                _DetailRow(
                  label: 'Amount',
                  value: NumberFormat('#,###').format(transaction.amount),
                ),
                const Divider(height: 40),

                // Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date', style: TextStyle(color: kGrey, fontSize: 16)),
                        Text(
                          DateFormat('MMM d, yyyy').format(transaction.date),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '( Add ${DateFormat('MMM d, yyyy HH:mm:ss').format(transaction.date)} )',
                        style: const TextStyle(color: kGrey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40),

                // Note
                _DetailRow(
                  label: 'Note',
                  value: transaction.note.isEmpty ? 'No Note' : transaction.note,
                ),
              ],
            ),
          ),

          // Bottom Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Add Edit logic here later if needed
                    },
                    child: const Text('Edit', style: TextStyle(color: kBlack, fontSize: 16)),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton(
                    onPressed: () => _showDeleteDialog(context),
                    child: const Text('Delete', style: TextStyle(color: kBlack, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(transaction.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Back to Home
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: kGrey, fontSize: 16))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}