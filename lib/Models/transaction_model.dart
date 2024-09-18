class TransactionModel {
  final String id;
  final String cardId;
  final String cardName;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final bool isExpense;
  // Recurrence fields
  final bool isRecurring;
  final String recurrenceType; // daily, weekly, monthly, yearly
  final int recurrenceInterval; // Interval between occurrences (e.g., every 2 days)
  final DateTime? endRecurrenceDate; // Optional end date for recurrence

  TransactionModel({
    required this.cardId,
    required this.cardName,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isRecurring = false,
    this.recurrenceType = '',
    this.recurrenceInterval = 0,
    this.endRecurrenceDate,
  }) : id = '';

  TransactionModel.withId({
    required this.id,
    required this.cardId,
    required this.cardName,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isRecurring = false,
    this.recurrenceType = '',
    this.recurrenceInterval = 0,
    this.endRecurrenceDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'cardName': cardName,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'isExpense': isExpense,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'recurrenceInterval': recurrenceInterval,
      'endRecurrenceDate': endRecurrenceDate?.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel.withId(
      id: id,
      cardId: map['cardId'],
      cardName: map['cardName'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      isExpense: map['isExpense'],
      isRecurring: map['isRecurring'] ?? false,
      recurrenceType: map['recurrenceType'] ?? '',
      recurrenceInterval: map['recurrenceInterval'] ?? 1,
      endRecurrenceDate: map['endRecurrenceDate'] != null
          ? DateTime.parse(map['endRecurrenceDate'])
          : null,
    );
  }
}
