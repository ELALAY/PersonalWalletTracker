import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// globals.dart
List<String> currencies = [
  'MAD',
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'CAD',
]; // Add your desired currencies
String selectedCurrency = 'USD'; // Default currency

//allowed colors
final List<Color> colorOptions = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.cyan,
  Colors.pink,
];

List<String> iconNames = [
  'beauty',
  'clothing',
  'entertainement',
  'food',
  'groceries',
  'history',
  'house',
  'salary',
  'stats',
  'transfer',
  'transportation',
  'utilities',
  'other',
  'financial_goal',
  'card_receive',
  'card_send',
  'add_transaction',
  'mastercard',
  'visa',
  // Add all your icon names here
];

Image categoryIcon(String name) {
  try {
    return Image.asset('lib/Images/${name.toLowerCase()}.png');
  } catch (e) {
    throw Exception('Firebase error: $e');
  }
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yy').format(date);
}

