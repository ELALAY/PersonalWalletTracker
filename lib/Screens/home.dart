import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Screens/new_expense_screen.dart';
import 'package:personalwallettracker/Screens/new_card_screen.dart';
import 'package:personalwallettracker/Components/my_button.dart';
import 'package:personalwallettracker/Screens/settings_screen.dart';
import 'package:personalwallettracker/Screens/stats_screen.dart';
import 'package:personalwallettracker/Screens/transaction_history.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Components/my_card.dart';
import '../Utils/firebase_db.dart';
import 'edit_card_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final pageController = PageController();
  List<CardModel> myCards = [];
  bool isLoading = true;
  int navIndex = 0;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  void reload() {
    fetchCards();
    pageController.addListener(() {
      final newIndex = pageController.page?.round() ?? 0;
      if (newIndex != pageIndex) {
        setState(() {
          pageIndex = newIndex;
        });
      }
    });
  }

  void fetchCards() async {
    List<CardModel> cards = await firebaseDatabasehelper.getCards();
    setState(() {
      myCards = cards;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    //header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payment_outlined, color: Colors.grey,),
                              Text(
                                'My ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.grey),
                              ),
                              Text(
                                'Cards',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              )
                            ],
                          ),
                          IconButton(
                              onPressed: newCardScreen,
                              icon: const Icon(
                                  Icons.add_circle_outline_outlined,
                                  color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
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
                        //send
                        GestureDetector(
                          onTap: () {},
                          child: const MyButton(
                            icon: Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                            ),
                            action: 'Top Up',
                          ),
                        ),
                        //pay
                        GestureDetector(
                          onTap: newExpenseScreen,
                          child: const MyButton(
                            icon: Icon(
                              Icons.payment_outlined,
                              color: Colors.white,
                            ),
                            action: 'Expense',
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
                          onTap: transactionSreenScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      //bottom navbar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.grey.shade300,
        currentIndex: navIndex,
        onTap: (index) {
          setState(() {
            navIndex = index;
          });
          // Handle navigation
          if (navIndex == 1) {
            settingScreen();
          }
        },
      ),
    );
  }

  void updateCardbalance(double newAmount) async {
    String cardId = myCards[pageIndex].id;
    CardModel card = await firebaseDatabasehelper.getCardById(cardId);
    firebaseDatabasehelper.updateCardBalance(cardId, card.balance + newAmount);
  }

  void newCardScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const NewCardScreen();
    }));
  }

  void settingScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const SettingsScreen(); // replace with your settings screen
    })).then((value) => reload());
  }

  void newExpenseScreen() {
    if (myCards.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddTransactionScreen(card: myCards[pageIndex]);
      })).then((value) => reload());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card selected')),
      );
    }
  }

  void transactionSreenScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TransactionHistoryScreen(
          card: myCards[pageIndex]); // replace with your settings screen
    })).then((value) => reload());
  }

  void statsScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const StatisticsScreen(); // replace with your settings screen
    })).then((value) => reload());
  }

  void navUpdateCard() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditCardScreen(card: myCards[pageIndex],); // replace with your settings screen
    })).then((value) => reload());
  }
}
