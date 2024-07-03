import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'disbursement_check.dart';
import 'admin_menu_window.dart';
import 'notifications.dart';
import 'package:ojt/widgets/card.dart';
import 'package:ojt/models/admin_transaction.dart';
import 'package:intl/intl.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  int pendingCount = 0;
  late Future<List<Transaction>> _transactionsFuture;
  List<Transaction> selectedTransactions = [];
  double totalSelectedAmount = 0.0; // Track the total selected amount
  bool allSelected = false;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactionDetails();
  }

  Future<List<Transaction>> _fetchTransactionDetails() async {
    try {
      var url = Uri.parse('http://192.168.68.119/localconnect/get_transaction.php');
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
                    transaction.onlineTransactionStatus == 'TND' ||
                    transaction.onlineTransactionStatus == 'T')
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

  void _toggleTransactionSelection(Transaction transaction) {
    setState(() {
      if (selectedTransactions.contains(transaction)) {
        selectedTransactions.remove(transaction);
      } else {
        selectedTransactions.add(transaction);
      }
      _calculateTotalSelectedAmount(selectedTransactions);
    });
  }

  Future<void> _approvedTransaction(List<Transaction> transactions) async {
    try {
      for (Transaction transaction in transactions) {
        final response = await http.post(
          Uri.parse('http://192.168.68.119/localconnect/approve.php'),
          body: {
            'doc_no': transaction.docNo,
            'doc_type': transaction.docType,
          },
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            // Handle success message if needed
            print('Transaction ${transaction.docNo} rejected successfully');
          } else {
            throw Exception(
                'Failed to approve transaction ${transaction.docNo}');
          }
        } else {
          throw Exception('Failed to approve transaction ${transaction.docNo}');
        }
      }
      // Show a single success message if all transactions were successfully declined
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transactions approved successfully')),
      );
    } catch (e) {
      print('Error rejeceting transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approve transactions: $e')),
      );
    }
  }
  Future<void> _rejectTransaction(List<Transaction> transactions) async {
    try {
      for (Transaction transaction in transactions) {
        final response = await http.post(
          Uri.parse('http://192.168.68.119/localconnect/reject.php'),
          body: {
            'doc_no': transaction.docNo,
            'doc_type': transaction.docType,
          },
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            // Handle success message if needed
            print('Transaction ${transaction.docNo} rejected successfully');
          } else {
            throw Exception(
                'Failed to reject transaction ${transaction.docNo}');
          }
        } else {
          throw Exception('Failed to reject transaction ${transaction.docNo}');
        }
      }
      // Show a single success message if all transactions were successfully declined
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transactions rejected successfully')),
      );
    } catch (e) {
      print('Error rejeceting transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting transactions: $e')),
      );
    }
  }

  void _calculateTotalSelectedAmount(List<Transaction> transactions) {
    double totalAmount = 0.0;
    transactions.forEach((transaction) {
      totalAmount += double.parse(transaction.checkAmount);
    });
    setState(() {
      totalSelectedAmount = totalAmount;
    });
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

  String _plusS(int pendingCount) {
    if (pendingCount > 1) {
      return 'Items';
    } else if (pendingCount == 1) {
      return 'Item';
    } else {
      return 'item'; // Handle other cases if needed
    }
  }

  Widget buildSelectAllButton(List<Transaction> transactions) {
    bool allSelected = selectedTransactions.length == transactions.length &&
        transactions.isNotEmpty;

    return IconButton(
      onPressed: () {
        setState(() {
          if (!allSelected) {
            selectedTransactions.clear();
            selectedTransactions.addAll(transactions);
          } else {
            selectedTransactions.clear();
          }
          _calculateTotalSelectedAmount(selectedTransactions);
        });
      },
      icon: Icon(
        allSelected ? Icons.check_box : Icons.check_box_outline_blank,
        size: 30,
      ),
    );
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
                borderRadius: BorderRadius.circular(21.0),
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
                                Text(
                                  _plusS(pendingCount),
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
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: screenSize.width * 0.01,
                            ),
                            Expanded(
                              child: Text(
                                'Total: ₱ ${NumberFormat('#,###.##').format(totalSelectedAmount)}',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            buildSelectAllButton(transactions),
                            Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(
                              width: screenSize.width * .01,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: transactions.map((transaction) {
                                return CustomCardExample(
                                  transaction: transaction,
                                  isSelectAll: false,
                                  showSelectAllButton: false,
                                  onSelectChanged: (bool isSelected) {
                                    _toggleTransactionSelection(transaction);
                                  },
                                  onSelectedAmountChanged:
                                      (double selectedAmount) {
                                    print(
                                        'Selected amount changed: $selectedAmount');
                                    // Handle selected amount change here if needed
                                  },
                                  isSelected: selectedTransactions
                                      .contains(transaction),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.0025),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: totalSelectedAmount > 0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: screenSize.width * 0.6,
          margin: EdgeInsets.only(
            bottom: screenSize.height *
                0.02, // Margin from bottom adjusted based on screen height
            right: screenSize.width *
                0.005, // Margin from right adjusted based on screen width
          ),
          padding: EdgeInsets.all(screenSize.width *
              0.02), // Padding adjusted based on screen width
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0), // Transparent background
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenSize.width *
                  0.05), // Border radius adjusted based on screen width
              topRight: Radius.circular(screenSize.width *
                  0.00), // Border radius adjusted based on screen width
              bottomLeft: Radius.circular(screenSize.width *
                  0.05), // Border radius adjusted based on screen width
              bottomRight: Radius.circular(0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: screenSize.width * 0.02),
              ElevatedButton.icon(
                onPressed: () {
                  _approvedTransaction(selectedTransactions);
                  // _handleApproveAction(selectedTransactions);
                },
                icon: Icon(Icons.check,
                    size: screenSize.width * 0.05,
                    color: Colors
                        .white), // Icon size adjusted based on screen width
                label: Text(
                  'Approve',
                  style: TextStyle(
                      fontSize: screenSize.width * 0.03,
                      color: Colors
                          .white), // Text size adjusted based on screen width
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                      vertical: screenSize.width *
                          0.015), // Padding adjusted based on screen width
                  backgroundColor: Colors.blue, // Blue background color
                  elevation: 0, // Remove shadow
                  shadowColor: Colors.transparent, // Remove shadow color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenSize.width *
                        0.04), // Button border radius adjusted based on screen width
                    side: BorderSide(
                        color: Colors.blue,
                        width: screenSize.width *
                            0.01), // Button border width adjusted based on screen width
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.01),
              ElevatedButton.icon(
                onPressed: () {
                  _rejectTransaction(selectedTransactions);
                },
                icon: Icon(Icons.cancel_rounded,
                    size: screenSize.width * 0.03,
                    color: Colors
                        .white), // Icon size adjusted based on screen width
                label: Text(
                  'Reject',
                  style: TextStyle(
                      fontSize: screenSize.width * 0.03,
                      color: Colors
                          .white), // Text size adjusted based on screen width
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                      vertical: screenSize.width *
                          0.015), // Padding adjusted based on screen width
                  backgroundColor: Colors.blue, // Blue background color
                  elevation: 0, // Remove shadow
                  shadowColor: Colors.transparent, // Remove shadow color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenSize.width *
                        0.04), // Button border radius adjusted based on screen width
                    side: BorderSide(
                        color: Colors.blue,
                        width: screenSize.width *
                            0.01), // Button border width adjusted based on screen width
                  ),
                ),
              ),
            ],
          ),
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
