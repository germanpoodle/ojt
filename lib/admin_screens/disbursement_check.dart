import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/admin_transaction.dart';
import '../widgets/card.dart';
import 'notifications.dart';
import 'admin_homepage.dart';
import 'admin_menu_window.dart';

class DisbursementCheque extends StatefulWidget {
  const DisbursementCheque({Key? key}) : super(key: key);

  @override
  _DisbursementChequeState createState() => _DisbursementChequeState();
}

class _DisbursementChequeState extends State<DisbursementCheque>
    with SingleTickerProviderStateMixin {
  int pendingCountT = 0;
  int pendingCountTnd = 0;
  late TabController _tabController;
  late Future<List<Transaction>> _transactionsFutureT;
  late Future<List<Transaction>> _transactionsFutureTnd;
  bool _selectAllTabT = false;
  bool _selectAllTabTnd = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _transactionsFutureT = _fetchTransactionDetails('t');
    _transactionsFutureTnd = _fetchTransactionDetails('tnd');
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<List<Transaction>> _fetchTransactionDetails(
      String onlineTransactionStatus) async {
    try {
      var url = Uri.parse(
          'http://127.0.0.1/localconnect/get_transaction.php?onlineTransactionStatus=$onlineTransactionStatus');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          List<Transaction> fetchedTransactions = jsonData
              .map((transaction) => Transaction.fromJson(transaction))
              .toList();
          setState(() {
            if (onlineTransactionStatus == 't') {
              pendingCountT = fetchedTransactions
                  .where((transaction) =>
                      transaction.onlineTransactionStatus == 't')
                  .length;
            } else if (onlineTransactionStatus == 'tnd') {
              pendingCountTnd = fetchedTransactions
                  .where((transaction) =>
                      transaction.onlineTransactionStatus == 'tnd')
                  .length;
            }
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
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMenuWindow()),
        );
        break;
    }
  }

  void _toggleSelectAllTabT() {
    setState(() {
      _selectAllTabT = !_selectAllTabT;
      _transactionsFutureT = _transactionsFutureT.then((transactions) {
        return transactions.map((transaction) {
          transaction.isSelected = _selectAllTabT;
          return transaction;
        }).toList();
      });
    });
  }

  void _toggleSelectAllTabTnd() {
    setState(() {
      _selectAllTabTnd = !_selectAllTabTnd;
      _transactionsFutureTnd = _transactionsFutureTnd.then((transactions) {
        return transactions.map((transaction) {
          transaction.isSelected = _selectAllTabTnd;
          return transaction;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Size screenSize = MediaQuery.of(context).size;

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
                  'Tasks',
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
                      size: 24,
                      color: Color.fromARGB(255, 233, 227, 227),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person,
                    size: 24,
                    color: Color.fromARGB(255, 233, 227, 227),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pendingCountT',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5,),
                  Text(
                    'Pending with Attachments',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'tahoma',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pendingCountTnd',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5,),
                  Text(
                    'Pending with no Attachments',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'tahoma',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(_transactionsFutureT, 't', _selectAllTabT,
                _toggleSelectAllTabT),
            _buildTabContent(_transactionsFutureTnd, 'tnd', _selectAllTabTnd,
                _toggleSelectAllTabTnd),
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
        currentIndex: 1,
        selectedItemColor: const Color.fromARGB(255, 0, 110, 255),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTabContent(Future<List<Transaction>> future, String status,
      bool selectAll, VoidCallback toggleSelectAll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: toggleSelectAll,
                icon: Icon(
                  selectAll ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 30,
                ),
              ),
              Text(
                'Select All',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Transaction>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions found!',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              } else {
                final List<Transaction> transactions = snapshot.data!;
                List<Transaction> filteredTransactions = transactions
                    .where((transaction) =>
                        transaction.onlineTransactionStatus == status)
                    .toList();

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions found!',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    return CustomCardExample(
                      transaction: filteredTransactions[index],
                      isSelected: filteredTransactions[index].isSelected,
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
