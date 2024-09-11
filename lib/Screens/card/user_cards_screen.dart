import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import 'package:personalwallettracker/Components/my_card.dart';

import '../../services/auth/auth_service.dart';
import 'edit_card_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  CardListScreenState createState() => CardListScreenState();
}

class CardListScreenState extends State<CardListScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  AuthService authService = AuthService();
  List<CardModel> _cards = [];
  bool _isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    fetchUser();
    _loadCards();
  }

  void fetchUser() {
    User? usertemp = authService.getCurrentUser();
    setState(() {
      user = usertemp;
    });
  }

  Future<void> _loadCards() async {
    try {
      final cards = await _firebaseDB.getUserCards(user!.uid);
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cards: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(_cards.length.toString()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Center(
                    child: MyCard(
                      cardHolder: card.cardHolderName,
                      balance: card.balance,
                      cardName: card.cardName,
                      cardType: card.cardType,
                      color: Color(card.color),
                      isArchived: card.isArchived,
                      onTap: () {
                        navUpdateCard(card);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void navUpdateCard(CardModel card) {
    if (_cards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditCardScreen(
          card: card,
        ); // replace with your settings screen
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card selected')),
      );
    }
  }
}
