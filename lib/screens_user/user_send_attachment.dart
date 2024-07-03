import 'dart:convert';
<<<<<<< HEAD
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;
=======
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../admin_screens/notifications.dart';
import '../models/user_transaction.dart';
<<<<<<< HEAD
import 'transmitter_homepage.dart';
import '../screens_user/user_menu.dart';
import '../screens_user/user_upload.dart';
import 'no_support.dart';
import 'user_add_attachment.dart';
import 'view_files.dart';
=======
import 'user_menu.dart';
import 'user_upload.dart';
import 'view_files.dart';
import 'user_add_attachment.dart';
>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd

class UserSendAttachment extends StatefulWidget {
  final Transaction transaction;
  final List selectedDetails;
  final List<Map<String, String>> attachments;

  const UserSendAttachment({
    Key? key,
    required this.transaction,
    required this.selectedDetails,
    required this.attachments,
  }) : super(key: key);

  @override
  _UserSendAttachmentState createState() => _UserSendAttachmentState();
}

class _UserSendAttachmentState extends State<UserSendAttachment> {
  int _selectedIndex = 0;
  bool _showRemarks = false;
  bool _isLoading = false;

  List<Map<String, String>> attachments = [];

  @override
  void initState() {
    super.initState();
    attachments = widget.attachments; // Initialize attachments list
  }

  String createDocRef(String docType, String docNo) {
    return '$docType#$docNo';
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

<<<<<<< HEAD
  Future<void> _uploadTransactionOrFile() async {
    if (widget.transaction != null && attachments.isNotEmpty) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      bool allUploadedSuccessfully = true;
      List<String> errorMessages = [];

      try {
        var uri =
            Uri.parse('http://192.168.68.119/localconnect/upload_pic.php');

        for (var attachment in attachments) {
          if (attachment['name'] != null &&
              attachment['bytes'] != null &&
              attachment['size'] != null) {
            var request = http.MultipartRequest('POST', uri);

            // Set form fields
            request.fields['doc_type'] = widget.transaction.docType.toString();
            request.fields['doc_no'] = widget.transaction.docNo.toString();
            request.fields['date_trans'] =
                widget.transaction.dateTrans.toString();

            // Prepare the file to be uploaded
            var pickedFile = PlatformFile(
              name: attachment['name']!,
              bytes: Uint8List.fromList(base64Decode(attachment['bytes']!)),
              size: int.parse(attachment['size']!),
            );

            if (pickedFile.bytes != null) {
              // Attach file to the request
              request.files.add(
                http.MultipartFile.fromBytes(
                  'file',
                  pickedFile.bytes!,
                  filename: pickedFile.name,
                ),
              );

              developer.log('Uploading file: ${pickedFile.name}');

              // Send the request and handle the response
              var response = await request.send();

              if (response.statusCode == 200) {
                var responseBody = await response.stream.bytesToString();
                developer.log('Upload response: $responseBody');

                // Check if the response body is a valid JSON
                if (responseBody.startsWith('{') &&
                    responseBody.endsWith('}')) {
                  var result = jsonDecode(responseBody);

                  if (result['status'] == 'success') {
                    setState(() {
                      // Update UI state after successful upload
                      attachments.removeWhere(
                          (element) => element['name'] == pickedFile.name);
                      attachments
                          .add({'name': pickedFile.name, 'status': 'Uploaded'});
                      developer.log(
                          'Attachments array after uploading: $attachments');
                    });
                  } else {
                    allUploadedSuccessfully = false;
                    errorMessages.add(result['message']);
                    developer.log('File upload failed: ${result['message']}');
                  }
                } else {
                  allUploadedSuccessfully = false;
                  errorMessages.add('Invalid response from server');
                  developer.log('Invalid response from server: $responseBody');
                }
              } else {
                allUploadedSuccessfully = false;
                errorMessages.add(
                    'File upload failed with status: ${response.statusCode}');
                developer.log(
                    'File upload failed with status: ${response.statusCode}');
              }
            } else {
              allUploadedSuccessfully = false;
              errorMessages.add('Error: attachment bytes are null or empty');
              developer.log('Error: attachment bytes are null or empty');
            }
          } else {
            allUploadedSuccessfully = false;
            errorMessages.add('Error: attachment name, bytes or size is null');
            developer.log('Error: attachment name, bytes or size is null');
          }
        }

        // Show single dialog based on the overall upload result
        if (allUploadedSuccessfully) {
          _showDialog(context, 'Success', 'All files uploaded successfully!');
        } else {
          _showDialog(context, 'Error',
              'Error uploading files:\n${errorMessages.join('\n')}');
        }
      } catch (e) {
        developer.log('Error uploading file or transaction: $e');
        _showDialog(
            context, 'Error', 'Error uploading file. Please try again later.');
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      developer.log('Error: widget.transaction or attachments is null');
      _showDialog(
          context, 'Error', 'Error uploading file. Please try again later.');
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

=======
  Future<void> _uploadTransaction() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      var uri = Uri.parse(
          'http://192.168.68.119/localconnect/UserUploadUpdate/update_OPS.php');
      var request = http.Request('POST', uri);

      // URL-encode the values
      var requestBody =
          'doc_type=${Uri.encodeComponent(widget.transaction.docType)}&doc_no=${Uri.encodeComponent(widget.transaction.docNo)}&date_trans=${Uri.encodeComponent(widget.transaction.dateTrans)}';

      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.body = requestBody;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var result = jsonDecode(responseBody);

        if (result['status'] == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );

          // Navigate back to previous screen (DisbursementDetailsScreen)
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Transaction upload failed with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error uploading transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error uploading transaction. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

>>>>>>> 53d7fb7cc0771b67d3f1fecbf18f3158e47864bd
  Widget buildDetailsCard(Transaction detail) {
    return Container(
      height: 450,
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
              const Spacer(),
              buildTable(detail),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () async {
                    // Navigate to Add Attachment Screen and wait for result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserAddAttachment(
                                transaction: detail,
                                selectedDetails: [],
                              )),
                    );

                    if (result != null && result is List<Map<String, String>>) {
                      setState(() {
                        widget.attachments.addAll(result);
                      });
                    }
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
        buildTableRow('Doc Ref', createDocRef(detail.docType, detail.docNo)),
        buildTableRow('Date', formatDate(detail.transDate)),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDetailsCard(widget.transaction),
            Spacer(), // Pushes the buttons to the bottom
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 16.0), // Add some bottom padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewFilesPage(
                              attachments: widget.attachments,
                              onDelete: (int index) {
                                setState(() {
                                  attachments.removeAt(index);
                                });
                                developer.log(
                                    'Attachment removed from UserSendAttachment: $index');
                              },
                              docType: '',
                              docNo: '',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.folder_open),
                      label: Text('View Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _uploadTransactionOrFile();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransmitterHomePage(
                                          key: Key('value')),
                                ),
                              );
                            },
                      icon: Icon(Icons.send),
                      label: Text('Send'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 79, 129, 189),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
