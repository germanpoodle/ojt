import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ojt/screens_user/no_support.dart';

import '../admin_screens/notifications.dart';
import '../models/user_transaction.dart';
import 'user_add_attachment.dart';
import 'user_menu.dart';
import 'user_upload.dart';

class DisbursementDetailsScreen extends StatefulWidget {
  final Transaction? transaction;
  final List selectedDetails;

  const DisbursementDetailsScreen({
    Key? key,
    this.transaction,
    this.selectedDetails = const [],
  }) : super(key: key);

  @override
  _DisbursementDetailsScreenState createState() =>
      _DisbursementDetailsScreenState();
}

<<<<<<< HEAD
<<<<<<< HEAD
String createDocRef(String docType, String docNo) {
=======
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
String createDocRef(
  String docType,
  String docNo,
) {
<<<<<<< HEAD
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
  return '$docType#$docNo';
}

class _DisbursementDetailsScreenState extends State<DisbursementDetailsScreen> {
  int _selectedIndex = 0;
  final bool _showRemarks = false;

  @override
  void initState() {
    super.initState();
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(date);
  }

  String formatAmount(double amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return currencyFormat.format(amount);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NoSupportScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuWindow()),
        );
        break;
    }
  }

  Widget buildDetailsCard(Transaction? detail) {
    if (detail == null) {
      return Center(
        child: Text(
          'No Transaction Details Available',
          style: TextStyle(fontSize: 18, fontFamily: 'Tahoma'),
        ),
      );
    }

    return Container(
      child: Card(
        semanticContainer: true,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildReadOnlyTextField(
                  'Transacting Party', detail.transactingParty),
<<<<<<< HEAD
<<<<<<< HEAD
              SizedBox(height: 20),
=======
              const Spacer(),
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
              const Spacer(),
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
              buildTable(detail),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserAddAttachment(
<<<<<<< HEAD
<<<<<<< HEAD
                              transaction: detail, selectedDetails: [])),
=======
                                transaction: detail,
                                selectedDetails: [],
                              )),
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
                                transaction: detail,
                                selectedDetails: [],
                              )),
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
                    );
                  },
                  child: Text('Add Attachment'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 79, 128, 189),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReadOnlyTextField(String label, String value) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 90, 119, 154)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
    );
  }

  Widget buildTable(Transaction detail) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      border: TableBorder.all(
        width: 1.0,
        color: Colors.black,
      ),
      children: [
<<<<<<< HEAD
<<<<<<< HEAD
        buildTableRow('Doc Ref', createDocRef(detail.docType, detail.docNo)),
=======
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
        buildTableRow(
          'Doc Ref',
          createDocRef(detail.docType, detail.docNo),
        ),
<<<<<<< HEAD
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
        buildTableRow('Date', formatDate(detail.transDate)),
        buildTableRow('Payee', detail.transactingParty),
        buildTableRow('Check', detail.checkNumber),
        buildTableRow('Bank', detail.bankName),
        buildTableRow('Amount', formatAmount(detail.checkAmount)),
        buildTableRow('Status', detail.transactionStatus),
        buildTableRow('Remarks', detail.remarks),
      ],
    );
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        buildTableCell(label),
        buildTableCell(value),
      ],
    );
  }

  Widget buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Tahoma',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 79, 128, 189),
        toolbarHeight: 77,
        title: Column(
          children: [
            Row(
              //RenderFlex Overflow Error
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
<<<<<<< HEAD
<<<<<<< HEAD
                Image.asset(
                  'logo.png',
                  width: 60,
                  height: 55,
                ),
                const SizedBox(width: 8),
                const Text(
                  'For Uploading',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Tahoma',
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
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications,
                      size: 24,
                      color: Color.fromARGB(255, 233, 227, 227),
=======
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
                Row(
                  children: [
                    Image.asset(
                      'logo.png',
                      width: 60,
                      height: 55,
<<<<<<< HEAD
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'For Uploading',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Tahoma',
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
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
<<<<<<< HEAD
<<<<<<< HEAD
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildDetailsCard(widget.transaction),
            ],
          ),
        ),
=======
        child:
            buildDetailsCard(widget.transaction), // Use widget.transaction here
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
=======
        child:
            buildDetailsCard(widget.transaction), // Use widget.transaction here
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 79, 128, 189),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file_outlined),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'No Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_sharp),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
