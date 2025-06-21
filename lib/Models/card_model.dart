import 'package:flutter/material.dart';

class CardModel {
  final String id;
  final String cardName;
  final double balance;
  final String ownerId;
  final String cardHolderName;
  final String cardType;
  final int color;
  final bool isArchived;
  final List<String> sharedWith;

  CardModel({
    required this.cardName,
    required this.balance,
    required this.cardHolderName,
    required this.ownerId,
    required this.cardType,
    required this.color,
    this.isArchived = false,
    this.sharedWith = const [],
  }) : id = '';

  CardModel.withId({
    required this.id,
    required this.cardName,
    required this.balance,
    required this.cardHolderName,
    required this.ownerId,
    required this.cardType,
    required this.color,
    this.isArchived = false,
    this.sharedWith = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'cardName': cardName,
      'balance': balance,
      'cardHolderName': cardHolderName,
      'ownerId': ownerId,
      'cardType': cardType,
      'color': color,
      'isArchived': isArchived,
      'sharedWith': sharedWith,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map, String id) {
    return CardModel.withId(
      id: id,
      cardName: map['cardName'],
      balance: (map['balance'] as num).toDouble(),
      cardHolderName: map['cardHolderName'],
      ownerId: map['ownerId'],
      cardType: map['cardType'],
      color: map['color'] ?? Colors.deepPurple,
      isArchived: map['isArchived'] ?? false,
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  CardModel toggleArchive() {
    return CardModel.withId(
      id: id,
      cardName: cardName,
      balance: balance,
      cardHolderName: cardHolderName,
      ownerId: ownerId,
      cardType: cardType,
      color: color,
      isArchived: !isArchived,
      sharedWith: sharedWith,
    );
  }

  // Optional: Add method to share the card with a new user
  CardModel addSharedUser(String userId) {
    final updatedSharedWith = List<String>.from(sharedWith)..add(userId);
    return CardModel.withId(
      id: id,
      cardName: cardName,
      balance: balance,
      cardHolderName: cardHolderName,
      ownerId: ownerId,
      cardType: cardType,
      color: color,
      isArchived: isArchived,
      sharedWith: updatedSharedWith,
    );
  }
}
