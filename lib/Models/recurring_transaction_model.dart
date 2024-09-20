class RecurringTransactionModel {
  final String id;
  final String ownerId;
  final String cardId;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final bool isExpense;
  // Recurrence fields
  final bool isArchived;
  //  final bool isReccuring;
  // final String recurrenceType; // daily, weekly, monthly, yearly
  // final int recurrenceInterval; // Interval between occurrences (e.g., every 2 days)
  // final DateTime? endRecurrenceDate; // Optional end date for recurrence

  RecurringTransactionModel({
    required this.ownerId,
    required this.cardId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isArchived = false,
  }) : id = '';

  RecurringTransactionModel.withId({
    required this.id,
    required this.ownerId,
    required this.cardId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'cardId': cardId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'isExpense': isExpense,
      'isArchived': isArchived,
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return RecurringTransactionModel.withId(
      id: id,
      ownerId: map['ownerId'],
      cardId: map['cardId'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      isExpense: map['isExpense'],
      isArchived: map['isArchived'] ?? false,
    );
  }
}
