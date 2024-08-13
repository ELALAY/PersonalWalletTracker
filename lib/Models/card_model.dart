import 'package:flutter/material.dart';

class CardModel {
  final String id;
  final String cardName;
  final double balance;
  final String cardHolderName;
  final String cardType;
  final int color;

  CardModel({
    required this.cardName,
    required this.balance,
    required this.cardHolderName,
    required this.cardType,
    required this.color,
  }): id = '';

  CardModel.withId({
    required this.id,
    required this.cardName,
    required this.balance,
    required this.cardHolderName,
    required this.cardType,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardName': cardName,
      'balance': balance,
      'cardHolderName': cardHolderName,
      'cardType': cardType,
      'color': color,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map, String id) {
    return CardModel.withId(
      id: id,
      cardName: map['cardName'],
      balance: map['balance'],
      cardHolderName: map['cardHolderName'],
      cardType: map['cardType'],
      color: map['color'] ?? Colors.deepPurple.value, // Default color
    );
  }
}
