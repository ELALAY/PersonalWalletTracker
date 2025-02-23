import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Components/my_drawer.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Models/recurring_transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/new_transaction_screen.dart';
import 'package:personalwallettracker/Components/my_buttons/my_image_button.dart';
import 'package:personalwallettracker/Screens/settings_screen.dart';
import 'package:personalwallettracker/Screens/transaction/recurring_transactions/recurring_transactions_screen.dart';
import 'package:personalwallettracker/Screens/transaction/stats_screen.dart';
import 'package:personalwallettracker/Screens/transaction/transaction_history.dart';
import 'package:personalwallettracker/Screens/transaction/transfer_money.dart';
import 'package:personalwallettracker/services/auth/auth_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Components/my_card.dart';
import '../services/realtime_db/firebase_db.dart';
import 'card/edit_card_screen.dart';
import 'card/new_card_screen.dart';
import 'goal/goals_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  AuthService authService = AuthService();
  final pageController = PageController();
  List<CardModel> myCards = [];
  bool isLoading = true;
  int pageIndex = 0;
  //user and profile info
  User? user;
  Person? personProfile;
  // uncreated recurring transactions
  List<RecurringTransactionModel> uncreatedTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchUserAndCards();
    isLoading = false;
  }

  Future<void> reload() async {
    isLoading = true;
    debugPrint('reloading...');
    fetchUserAndCards();
    pageController.addListener(() {
      final newIndex = pageController.page?.round() ?? 0;
      if (newIndex != pageIndex) {
        setState(() {
          pageIndex = newIndex;
        });
      }
    });
    debugPrint('reloaded');
    isLoading = false;
  }

  void fetchUserAndCards() async {
    try {
      // Fetch the user
      User? userTemp = authService.getCurrentUser();
      if (userTemp != null) {
        debugPrint('got user: ${userTemp.email}');
        // Fetch user profile
        Person? personProfileTemp =
            await firebaseDatabasehelper.getPersonProfile(userTemp.uid);
        personProfileTemp != null
            ? debugPrint('got user: ${personProfileTemp.email}')
            : debugPrint('no user profile');
        setState(() {
          user = userTemp;
          personProfile = personProfileTemp;
        });

        // Fetch cards only after user and personProfile are set
        List<CardModel> cards =
            await firebaseDatabasehelper.getUserActiveCards(userTemp.uid);
        setState(() {
          myCards = cards;
          isLoading = false;
        });

        checkUncreatedRecurringTransactions();
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint("Error fetching user or cards: $e");
    }
  }

  void checkUncreatedRecurringTransactions() async {
    if (user != null) {
      List<RecurringTransactionModel> uncreatedTransactionstemp = [];
      List<RecurringTransactionModel> recurringTransactions =
          await firebaseDatabasehelper
              .fetchUserRecurringTransactions(user!.uid);

      DateTime now = DateTime.now(); // Get the current date
      String currentMonthYear = DateFormat('yyyyMM')
          .format(now); // To compare for monthly recurrences

      for (var transaction in recurringTransactions) {
        if (!transaction.isArchived) {
          // Check if the recurring transaction next month is today's month
          if (transaction.recurrenceType == 0 &&
              DateFormat('yyyyMM').format(transaction.date) ==
                  currentMonthYear) {
            // Handle recurring transaction for today (e.g., monthly)
            uncreatedTransactionstemp.add(transaction);
          }
        }
      }

      setState(() {
        uncreatedTransactions = uncreatedTransactionstemp;
        debugPrint(
            'ucreated rec transactions: ${uncreatedTransactions.length.toString()}');
      });
    } else {
      debugPrint('No User Found!');
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
          IconButton(
              onPressed: newCardScreen,
              icon: const Icon(Icons.add_circle_outline_outlined,
                  color: Colors.grey)),
          uncreatedTransactions.isNotEmpty
              ? IconButton(
                  onPressed: showUncreatedRecurringTransactions,
                  icon: const Icon(
                    Icons.notifications_active,
                    color: Colors.deepOrange,
                  ))
              : IconButton(
                  onPressed: showUncreatedRecurringTransactions,
                  icon: const Icon(Icons.notifications_outlined))
        ],
      ),
      drawer: user != null && personProfile != null
          ? MyDrawer(
              user: user!,
              personProfile: personProfile!,
              myCards: myCards,
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LiquidPullToRefresh(
              onRefresh: () async {
                reload();
              },
              backgroundColor: Colors.deepPurple.shade200,
              height: 200.0,
              color: Colors.deepPurple,
              showChildOpacityTransition: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    //cards
                    SizedBox(
                      height: 200.0,
                      child: PageView(
                        controller: pageController,
                        scrollDirection: Axis.horizontal,
                        children: myCards.isNotEmpty
                            ? myCards
                                .map((card) => MyCard(
                                      cardHolder: card.cardHolderName,
                                      balance: card.balance,
                                      cardName: card.cardName,
                                      cardType: card.cardType,
                                      color: Color(card.color),
                                      onTap: navUpdateCard,
                                      currency: personProfile!.default_currency,
                                    ))
                                .toList()
                            : [
                                const Center(
                                  child: Text(
                                    'No Cards Found! Create a Card!',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200),
                                  ),
                                )
                              ],
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    myCards.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: pageController,
                            count: myCards.length,
                            effect: const ExpandingDotsEffect(
                                activeDotColor: Colors.deepPurple),
                          )
                        : Container(),
                    const SizedBox(
                      height: 25.0,
                    ),
                    //buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //tranfer
                        GestureDetector(
                          onTap: navTransferMoney,
                          child: const MyImageButton(
                            icon: 'cards',
                            action: 'Transfer',
                          ),
                        ),
                        //new transaction
                        GestureDetector(
                          onTap: newTransactionScreen,
                          child: const MyImageButton(
                            icon: 'transactions',
                            action: 'Transaction',
                          ),
                        ),
                        //financial goal
                        GestureDetector(
                          onTap: navGoalScreen,
                          child: const MyImageButton(
                            icon: 'target',
                            action: 'Goal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Text(
                      'Insights',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    //tiles of stats & transactions
                    Column(
                      children: [
                        // stats tile
                        ListTile(
                          tileColor: Colors.deepOrange,
                          leading: SizedBox(
                            height: 35.0,
                            child: Image.asset(
                              'lib/Images/stats.png',
                              color: Colors.white,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Statistics',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: const Text(
                            'payments & incomes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onTap: statsScreen,
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        //history tile
                        ListTile(
                          tileColor: Colors.deepOrange,
                          leading: SizedBox(
                            height: 35.0,
                            child: Image.asset(
                              'lib/Images/history.png',
                              color: Colors.white,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Transactions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: const Text(
                            'Transactions history',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          onTap: transactionhistoryScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void showUncreatedRecurringTransactions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (uncreatedTransactions.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepOrange.shade200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      leading: const Text(
                        'Check Recurring Transactions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15),
                      ),
                      trailing: const Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      onTap:
                          recurringTransactionsScreen, // Here the function is being called
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void recurringTransactionsScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return RecurringTransactionsScreen(
        user: user!.uid,
        personProfile: personProfile!,
        myCards: myCards,
      );
    }));
  }

  void updateCardbalance(double newAmount) async {
    String cardId = myCards[pageIndex].id;
    CardModel card = await firebaseDatabasehelper.getCardById(cardId);
    firebaseDatabasehelper.updateCardBalance(cardId, card.balance + newAmount);
  }

  void newCardScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NewCardScreen(
        user: user!,
        personProfile: personProfile!,
      );
    }));
  }

  void navSettingScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsScreen(
        person: personProfile!,
        user: user!.uid
      ); // replace with your settings screen
    })).then((value) => reload());
  }

  void newTransactionScreen() {
    if (myCards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddTransactionScreen(card: myCards[pageIndex], user: user!.uid,);
      })).then((value) => reload());
    } else {
      showInfoSnachBar('No card selected!');
    }
  }

  void transactionhistoryScreen() {
    if (myCards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TransactionHistoryScreen(
          card: myCards[pageIndex],
          myCards: myCards,
          currency: personProfile!.default_currency,
          user: user!.uid
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      showInfoSnachBar('No card selected!');
    }
  }

  void statsScreen() {
    if (myCards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return StatisticsScreen(
          myCards: myCards,
          currency: personProfile!.default_currency,
          user: user!.uid
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      showInfoSnachBar('No card selected!');
    }
  }

  void navUpdateCard() {
    if (myCards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditCardScreen(
          card: myCards[pageIndex],
          currency: personProfile!.default_currency,
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card selected')),
      );
    }
  }

  void navTransferMoney() {
    if (myCards.length > 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TransferMoney(
          myCards: myCards,
          currency: personProfile!.default_currency,
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      showInfoSnachBar('Not enough cards!!');
    }
  }

  void navGoalScreen() {
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return GoalsOverviewScreen(
          user: user!,
          myCards: myCards,
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is found')),
      );
    }
  }

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.red.shade400),
        backgroundColor: Colors.red,
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ));
  }

  void showWarningSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.amber.shade400),
        backgroundColor: Colors.amber,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.white,
        ));
  }

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.lightBlueAccent.shade400),
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ));
  }

  void showSuccessSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.green.shade400),
        backgroundColor: Colors.green,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ));
  }
}
