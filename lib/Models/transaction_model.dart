class TransactionModel {
  final String id;
  final String cardId;
  final String cardName;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final bool isExpense;
  final bool
      isRecurring; // denotes if the transaction has been created as a recurring transaction

  TransactionModel({
    required this.cardId,
    required this.cardName,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.isRecurring = false,
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
    );
  }
}
