import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'disbursement_check.dart';
import 'admin_menu_window.dart';
import 'notifications.dart';
import 'package:ojt/widgets/card.dart';
import 'package:ojt/models/admin_transaction.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  int pendingCount = 0;
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactionDetails();
  }

  Future<List<Transaction>> _fetchTransactionDetails() async {
    try {
      var url = Uri.parse('http://127.0.0.1/localconnect/get_transaction.php');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          List<Transaction> fetchedTransactions = jsonData
              .map((transaction) => Transaction.fromJson(transaction))
              .toList();
          setState(() {
            pendingCount = fetchedTransactions
                .where((transaction) =>
                    transaction.onlineTransactionStatus == 'tnd' ||
                    transaction.onlineTransactionStatus == 't')
                .length;
          });
          return fetchedTransactions;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load transaction details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch transaction details: $e');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to Home (AdminHomePage)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DisbursementCheque()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMenuWindow()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 79, 128, 189),
        toolbarHeight: 77,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'logo.png',
                  width: 60,
                  height: 55,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 233, 227, 227),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: screenSize.width * 0.02),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications,
                      size: 24, // Adjust size as needed
                      color: Color.fromARGB(255, 233, 227, 227),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person,
                    size: 24, // Adjust size as needed
                    color: Color.fromARGB(255, 233, 227, 227),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.03,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DisbursementCheque()),
                );
              },
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(21.0), // Change the radius as needed
                child: Container(
                  color: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  height: 208,
                  width: screenSize.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disbursements \nfor approval',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    fontSize: 66,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  'items',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10, bottom: 85),
                        child: const Icon(
                          Icons.content_paste,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: FutureBuilder<List<Transaction>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No transactions found as of today.',
                      style: TextStyle(fontSize: 12),
                    ));
                  } else {
                    final List<Transaction> transactions = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: transactions.map((transaction) {
                          return CustomCardExample(transaction: transaction,isSelected: false,);
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_sharp),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_sharp),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 110, 255),
        onTap: _onItemTapped,
      ),
    );
  }
}
