import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ojt/transmittal_screens/fetching_data.dart';

import '../admin_screens/notifications.dart';
import '../models/user_transaction.dart';
import '../screens_user/user_menu.dart';
import 'view_attachment.dart';

class ReviewData extends StatefulWidget {
  final Transaction transaction;
  final List<String> selectedDetails;

  ReviewData({
    Key? key,
    required this.transaction,
    required this.selectedDetails,
  }) : super(key: key);

  @override
  _ReviewDataState createState() => _ReviewDataState();
}

String createDocRef(String docType, String docNo) {
  return '$docType#$docNo';
}

class _ReviewDataState extends State<ReviewData> {
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
          MaterialPageRoute(builder: (context) => const TransmittalHomePage()),
        );
        break;
      case 1:
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => DisbursementDetailsScreen()),
        // );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuWindow()),
        );
        break;
    }
  }

  Widget buildDetailsCard(Transaction detail) {
    return Card(
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
            SizedBox(height: 20),
            buildTable(detail),
            SizedBox(height: 20),
          ],
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
        buildTableRow('Doc Ref', createDocRef(detail.docType, detail.docNo)),
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
                  'For Transmittal',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildDetailsCard(widget.transaction),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Row(
                      children: [
                        Icon(Icons.folder_open),
                        Text('  View Files'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransViewAttachments(
                            docType:
                                'your_doc_type', // Replace with actual docType
                            docNo: 'your_doc_no', // Replace with actual docNo
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Row(
                      children: [
                        Icon(Icons.reviews),
                        Text('  Review'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 79, 129, 189),
                    ),
                    onPressed: () {
                      // add your button press logic here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
