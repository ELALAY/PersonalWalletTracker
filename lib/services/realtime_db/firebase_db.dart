import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../Models/card_model.dart';
import '../../Models/category_model.dart';
import '../../Models/person_model.dart';
import '../../Models/transaction_model.dart';

class FirebaseDB {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//--------------------------------------------------------------------------------------
//********  Cards Functions**********/
//--------------------------------------------------------------------------------------

  // Add a new card with auto-generated ID
  Future<bool> addCard(CardModel card) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('cards').add(card.toMap());
      card = await getCardById(docRef.id);
      return true;
    } catch (e) {
      debugPrint('Error adding card: $e');
      return false;
    }
  }

  // Fetch all cards
  Future<List<CardModel>> getCards() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('cards').get();
      return querySnapshot.docs
          .map((doc) =>
              CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      rethrow;
    }
  }

  // Update an existing card
  Future<void> updateCard(CardModel card) async {
    try {
      // Reference to the 'cards' collection and the specific document to update
      _firestore.collection('cards').doc(card.id).update(card.toMap());
      
      debugPrint('Card updated successfully');
    } catch (e) {
      debugPrint('Error updating card: $e');
    }
  }

  Future<CardModel> getCardById(String cardId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('cards').doc(cardId).get();
      if (doc.exists) {
        return CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw Exception('Card not found');
      }
    } catch (e) {
      throw Exception('Error fetching card: $e');
    }
  }

  // Method to update card balance
  Future<void> updateCardBalance(String cardId, double newBalance) async {
    debugPrint("Updating balance for card $cardId to $newBalance");
    try {
      await _firestore.collection('cards').doc(cardId).update({
        'balance': newBalance,
      });
    } catch (e) {
      debugPrint('Error updating card balance: $e');
    }
  }

//--------------------------------------------------------------------------------------
//********  Transaction Functions**********/
//--------------------------------------------------------------------------------------

  Future<TransactionModel> getTransactionById(String transactionId) async {
    try {
      debugPrint('fething transaction $transactionId');
      DocumentSnapshot doc =
          await _firestore.collection('cards').doc(transactionId).get();
      if (doc.exists) {
        return TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      } else {
        throw Exception('Transaction not found');
      }
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }  

  // Add a new transaction with auto-generated ID
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toMap());
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  // Fetch all transactions
  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('transactions').get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      rethrow;
    }
  }

  // Fetch transactions by card ID
  Future<List<TransactionModel>> fetchTransactionsByCardId(
      String cardId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('cardId', isEqualTo: cardId)
          .get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions by card ID: $e');
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
//********  Category Functions**********/
//--------------------------------------------------------------------------------------

  // Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => Category.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Create a new category
  Future<void> createCategory(Category category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

//--------------------------------------------------------------------------------------
//********  Person Functions**********/
//--------------------------------------------------------------------------------------
  Future<Person?> getPersonProfilePerson(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('persons').doc(uid).get();

      if (documentSnapshot.exists) {
        // Create a Person object from the document data
        Map<String, dynamic> data = documentSnapshot.data()!;
        Person person = Person.fromMap(data, uid);
        return person;
      } else {
        debugPrint('No user profile found for uid: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPersonProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('persons').doc(uid).get();

      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      } else {
        debugPrint('No user profile found for uid: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPersonProfileByUsername(
      String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('persons')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to return the first match
        return querySnapshot.docs.first.data();
      } else {
        debugPrint('No user profile found for username: $username');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<List<Person>> getAllPersons() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('persons').get();
      List<Person> allPersons = querySnapshot.docs
          .map((doc) => Person.fromMap(doc.data(), doc.id))
          .toList();
      return allPersons;
    } catch (e) {
      debugPrint('Error fetching all persons: $e');
      return [];
    }
  }
}
