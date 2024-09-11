import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../Models/card_model.dart';
import '../../Models/category_model.dart';
import '../../Models/goal_model.dart';
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

  // Fetch cards where ownerId matches the given user ID and isArchived is false
  // Fetch cards where ownerId matches the given user ID
  Future<List<CardModel>> getUserActiveCards(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('cards')
          .where('ownerId', isEqualTo: uid)
          .where('isArchived', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      rethrow;
    }
  } 

  // Fetch cards where ownerId matches the given user ID
  Future<List<CardModel>> getUserCards(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('cards')
          .where('ownerId', isEqualTo: uid)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      rethrow;
    }
  }

  // Fetch all cards
  Future<List<CardModel>> getAllCards() async {
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

  // Method to delete a card
  Future<void> deleteCard(String cardId) async {
    try {
      //delete all transactions related to the card
      deleteTransactionsByCardId(cardId);
      //delete card
      await _firestore.collection('cards').doc(cardId).delete();
    } catch (e) {
      debugPrint('Error deleting card: $e');
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
//********  Transaction Functions**********/
//--------------------------------------------------------------------------------------

  //delete transaction by ID
  Future<void> deleteTransactionsById(String transactionId) async {
    try {
      TransactionModel transaction = await getTransactionById(transactionId);
      CardModel card = await getCardById(transaction.cardId);
      final updatedCard = CardModel.withId(
        id: card.id,
        cardName: card.cardName,
        balance: transaction.isExpense
            ? card.balance + transaction.amount
            : card.balance - transaction.amount,
        cardHolderName: card.cardHolderName,
        ownerId: card.ownerId,
        cardType: card.cardType,
        color: card.color,
      );
      updateCard(updatedCard);
      // Fetch transactions associated with the card
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      debugPrint('Error deleting transactions: $e');
      rethrow;
    }
  }

  //delete transaction by ID
  Future<bool> deleteTransaction(TransactionModel transaction) async {
    try {
      CardModel card = await getCardById(transaction.cardId);
      final updatedCard = CardModel.withId(
        id: card.id,
        cardName: card.cardName,
        balance: transaction.isExpense
            ? card.balance + transaction.amount
            : card.balance - transaction.amount,
        cardHolderName: card.cardHolderName,
        ownerId: card.ownerId,
        cardType: card.cardType,
        color: card.color,
      );
      updateCard(updatedCard);
      // Fetch transactions associated with the card
      await _firestore.collection('transactions').doc(transaction.id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting transactions: $e');
      return false;
    }
  }

  // Method to delete transactions by card ID
  Future<void> deleteTransactionsByCardId(String cardId) async {
    try {
      //update the card balance if the amount of the transaction has changed
      CardModel card = await getCardById(cardId);
      final updatedCard = CardModel.withId(
        id: card.id,
        cardName: card.cardName,
        balance: 0,
        cardHolderName: card.cardHolderName,
        ownerId: card.ownerId,
        cardType: card.cardType,
        color: card.color,
      );
      updateCard(updatedCard);
      // Fetch transactions associated with the card
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('cardId', isEqualTo: cardId)
          .get();

      // Delete all fetched transactions
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting transactions: $e');
      rethrow;
    }
  }

  // fetch transaction by ID
  Future<TransactionModel> getTransactionById(String transactionId) async {
    if (transactionId.isNotEmpty) {
      try {
        debugPrint('fetching transaction $transactionId');
        DocumentSnapshot doc = await _firestore
            .collection('transactions')
            .doc(transactionId)
            .get();
        if (doc.exists) {
          return TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id);
        } else {
          throw Exception('Transaction not found');
        }
      } catch (e) {
        throw Exception('Error fetching transaction: $e');
      }
    } else {
      throw Exception('Transaction ID cannot be empty');
    }
  }

  // Update an existing card
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      debugPrint('getting current state of transaction1 ${transaction.id}');
      // Fetch the current state of the transaction to check the changes
      TransactionModel transactionTemp =
          await getTransactionById(transaction.id);
      debugPrint('Fetched transaction');

      // Update the card balance if the amount of the transaction has changed
      if (transactionTemp.amount != transaction.amount) {
        debugPrint('Updating card balance');
        CardModel card = await getCardById(transaction.cardId);
        debugPrint('Card: ${card.cardName}');

        final updatedCard = CardModel.withId(
          id: card.id,
          cardName: card.cardName,
          balance: transaction.isExpense
              ? card.balance - transactionTemp.amount + transaction.amount
              : card.balance + transactionTemp.amount - transaction.amount,
          cardHolderName: card.cardHolderName,
          ownerId: card.ownerId,
          cardType: card.cardType,
          color: card.color,
        );
        await updateCard(updatedCard);
      }

      debugPrint('Updating transaction');
      // Update transaction in Firestore
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());

      debugPrint('Transaction updated successfully');
    } catch (e) {
      debugPrint('Error updating transaction: ${e.toString()}');
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

  //fetch transactions by category and by card
  Future<List<TransactionModel>> fetchTransactionsByCategoryAndCard(
      String category, String cardId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('cardId', isEqualTo: cardId)
          .get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions by category: $e');
      rethrow;
    }
  }

  // Fetch transactions by category
  Future<List<TransactionModel>> fetchTransactionsByCategory(
      String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('category', isEqualTo: category)
          .get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions by category: $e');
      rethrow;
    }
  }

  // Fetch transactions by card ID
  Future<List<TransactionModel>> fetchUserTransactions(String cardId) async {
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

  Future<void> transferMoney({
    required CardModel fromCard,
    required CardModel toCard,
    required double amount,
  }) async {
    try {
      // Fetch the cards from Firebase
      DocumentSnapshot fromCardSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .doc(fromCard.id)
          .get();
      DocumentSnapshot toCardSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .doc(toCard.id)
          .get();

      if (fromCardSnapshot.exists && toCardSnapshot.exists) {
        double fromCardBalance = fromCardSnapshot['balance'];
        double toCardBalance = toCardSnapshot['balance'];

        if (fromCardBalance >= amount) {
          // Update the balances
          await FirebaseFirestore.instance
              .collection('cards')
              .doc(fromCard.id)
              .update({'balance': fromCardBalance - amount});
          await FirebaseFirestore.instance
              .collection('cards')
              .doc(toCard.id)
              .update({'balance': toCardBalance + amount});

          TransactionModel sendTransaction = TransactionModel(
              cardId: fromCard.id,
              cardName: fromCard.cardName,
              amount: amount,
              category: 'Transfer',
              date: DateTime.now(),
              description: 'Money Transfer',
              isExpense: true);
          TransactionModel receiverTransaction = TransactionModel(
              cardId: toCard.id,
              cardName: toCard.cardName,
              amount: amount,
              category: 'Transfer',
              date: DateTime.now(),
              description: 'Money Transfer',
              isExpense: false);

          // Optionally, (Sender) record the transaction in a transactions collection
          await FirebaseFirestore.instance
              .collection('transactions')
              .add(sendTransaction.toMap());
          // Optionally, (Receiver) record the transaction in a transactions collection
          await FirebaseFirestore.instance
              .collection('transactions')
              .add(receiverTransaction.toMap());

          debugPrint('Transfer successful!');
        } else {
          throw Exception('Insufficient balance on the source card.');
        }
      } else {
        throw Exception('One or both cards do not exist.');
      }
    } catch (e) {
      debugPrint('Error during transfer: $e');
    }
  }

//--------------------------------------------------------------------------------------
//********  Category Functions**********/
//--------------------------------------------------------------------------------------

  // Fetch all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  //fetch category
  Future<CategoryModel> fetchCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('category', isEqualTo: category)
          .get();

      // Category found, return an instance of CategoryModel
      var doc = querySnapshot.docs.first;
      return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error fetching category: $e');
      throw Exception('Error fetching category');
    }
  }

  //check category
  Future<bool> checkCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: category)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('error fetching category $e');
      return true;
    }
  }

  //update category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // Update transaction in Firestore
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
    } catch (e) {
      debugPrint('error updating category');
    }
  }

  // Delete transaction
  Future<void> deleteCategory(CategoryModel category) async {
    try {
      debugPrint('fetching transactions for ${category.name}');
      //delete transactions of this categories
      List<TransactionModel> transactions =
          await fetchTransactionsByCategory(category.name);
      if (transactions.isNotEmpty) {
        for (TransactionModel transaction in transactions) {
          await deleteTransaction(transaction);
        }
      }
      //delete category
      await _firestore.collection('categories').doc(category.id).delete();
      debugPrint('category deleted');
    } catch (e) {
      debugPrint('error deleting category $e');
    }
  }

  // Create a new category
  Future<bool> createCategory(CategoryModel category) async {
    try {
      bool exists = await checkCategory(category.name);
      if (exists) {
        debugPrint('Category Already Exists');
        return false;
      } else {
        await _firestore.collection('categories').add(category.toMap());
        return true;
      }
    } catch (e) {
      return false;
    }
  }

//--------------------------------------------------------------------------------------
//********  Person Functions**********/
//--------------------------------------------------------------------------------------
  Future<Person?> getPersonProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('persons').doc(uid).get();

      if (documentSnapshot.exists) {
        return Person.fromMap(documentSnapshot.data()!, uid);
      } else {
        debugPrint('No user profile found for uid: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Person?> getPersonProfileByUsername(String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('persons')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to return the first match
        return Person.fromMap(
            querySnapshot.docs.first.data(), querySnapshot.docs.first['id']);
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

  Future<void> updatePersonProfile(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      // Update the user's profile data in Firestore
      await _firestore.collection('users').doc(userId).update({
        'username': updatedData['username'],
        'profile_picture': updatedData['profile_picture'],
      });
      debugPrint('Profile updated successfully.');
    } catch (e) {
      // Log the error with a specific message
      debugPrint('Failed to update profile: $e');

      // Check if the error is a FirebaseException to provide more specific feedback
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      } else {
        throw Exception('Unknown error occurred while updating profile');
      }
    }
  }

//--------------------------------------------------------------------------------------
//********  Goal Functions**********/
//--------------------------------------------------------------------------------------

  Future<void> addGoal(GoalModel goal) async {
    await _firestore.collection('goals').add(goal.toMap());
  }

  Future<List<GoalModel>> getGoals(User user) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('goals')
        .where('uid', isEqualTo: user.uid)
        .get();
    return querySnapshot.docs
        .map((doc) =>
            GoalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteGoal(GoalModel goal) async {
    debugPrint('deleting ${goal.name}');
    await _firestore.collection('goals').doc(goal.id).delete();
  }

  Future<void> addFieldToAllRecords() async {
    try {
      // Fetch all documents in the collection
      QuerySnapshot querySnapshot =
          await _firestore.collection('cards').get();

      // Iterate through each document
      for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
        // Add the new field to each document
        await _firestore.collection('cards').doc(docSnapshot.id).update({
          'isArchived': false,
        });
      }

      debugPrint("Field added successfully to all records.");
    } catch (e) {
      debugPrint("Error updating documents: $e");
    }
  }
}
