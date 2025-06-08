import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RecurringTransactionModel {
  final String id;
  final String ownerId;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final bool isExpense;
  // Recurrence fields
  final bool isArchived;
  //  final bool isReccuring;
  final int recurrenceType; // Monthly, Weekly, Bi-weekly
  // final int recurrenceInterval; // Interval between occurrences (e.g., every 2 days)
  // final DateTime? endRecurrenceDate; // Optional end date for recurrence

  RecurringTransactionModel({
    required this.ownerId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isArchived = false,
    required this.recurrenceType,
  }) : id = '';

  RecurringTransactionModel.withId({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isArchived = false,
    required this.recurrenceType,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'isExpense': isExpense,
      'isArchived': isArchived,
      'recurrenceType': recurrenceType,
    };
  }

  factory RecurringTransactionModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return RecurringTransactionModel.withId(
      id: id,
      ownerId: map['ownerId'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      isExpense: map['isExpense'],
      isArchived: map['isArchived'] ?? false,
      recurrenceType: map['recurrenceType'],
    );
  }
}
