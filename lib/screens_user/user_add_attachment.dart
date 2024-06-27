import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/user_transaction.dart';
import 'user_homepage.dart';
import 'user_menu.dart';
import 'user_send_attachment.dart';
import 'user_upload.dart';

class UserAddAttachment extends StatefulWidget {
  final Transaction transaction;

  const UserAddAttachment({
    Key? key,
    required this.transaction,
    required List selectedDetails,
  }) : super(key: key);

  @override
  _UserAddAttachmentState createState() => _UserAddAttachmentState();
}

class _UserAddAttachmentState extends State<UserAddAttachment> {
  int _selectedIndex = 0; // Initialize with the correct index for Upload
  List<Map<String, String>> attachments = [];
  String? _fileName;
  PlatformFile? _pickedFile;
  bool _isLoading = false;

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

  Future<void> _pickFile() async {
    developer.log('Picking file...');
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _fileName = _pickedFile?.name ?? 'Unknown';
        attachments.add({'name': _fileName!, 'status': 'Selected'});
        developer.log('Attachments array after adding: $attachments');
      });
      developer.log('File picked: $_fileName');
    } else {
      developer.log('File picking cancelled');
    }
  }

  Future<void> _uploadFile(PlatformFile pickedFile) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.68.111/localconnect/UserUploadUpdate/update_TS.php'),
      );

      // Add the 'doc_type', 'doc_no', and 'date_trans' fields to the request
      request.fields['doc_type'] = widget.transaction.docType.toString();
      request.fields['doc_no'] = widget.transaction.docNo.toString();
      request.fields['date_trans'] = widget.transaction.dateTrans.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          pickedFile.bytes!,
          filename: pickedFile.name,
        ),
      );

      developer.log('Uploading file: ${pickedFile.name}');
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        developer.log('Upload response: $responseBody');

        try {
          var result = jsonDecode(responseBody);
          if (result['status'] == 'success') {
            setState(() {
              attachments
                  .removeWhere((element) => element['name'] == _fileName);
              attachments.add({'name': _fileName!, 'status': 'Uploaded'});
              developer.log('Attachments array after uploading: $attachments');
            });

            _showDialog(
              context,
              'Success',
              'File uploaded successfully!',
            );

            // Navigate to UserSendAttachment screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserSendAttachment(
                  transaction: widget.transaction, // Pass the transaction
                  selectedDetails: [], attachments: [], // Pass the selected details, adjust based on your requirements
                ),
              ),
            );

            
          } else {
            _showDialog(
              context,
              'Error',
              'File upload failed: ${result['message']}',
            );
            developer.log('File upload failed: ${result['message']}');
          }
        } catch (e) {
          _showDialog(
            context,
            'Error',
            'Error uploading file. Please try again later.',
          );
          developer.log('Error parsing upload response: $e');
        }
      } else {
        _showDialog(
          context,
          'Error',
          'File upload failed with status: ${response.statusCode}',
        );
        developer.log('File upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error uploading file: $e');
      _showDialog(
        context,
        'Error',
        'Error uploading file. Please try again later.',
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
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
//   Future<Uint8List> _getFileBytes(PlatformFile pickedFile) async {
//   // Get the bytes of the picked file
//   final bytes = await pickedFile.openRead().toBytes();
//   return bytes;
// }

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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => NotificationScreen()),
                      // );
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Attachment',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.all(24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    onPressed: _pickFile,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Click to upload',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            'Max. File Size: 5Mb',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_fileName != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Selected file: $_fileName'),
                    ),
                  const SizedBox(height: 20.0),
                  for (var attachment in attachments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: _buildAttachmentItem(
                          attachment['name']!, attachment['status']!),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              attachments.clear();
                            });
                            Navigator.pop(context);
                            developer.log('Discard button pressed');
                          },
                          child: const Text('Discard'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_pickedFile != null) {
                              await _uploadFile(_pickedFile!);
                            } else {
                              developer.log('No file selected');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Attach File'),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading) // Show loading indicator when uploading
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildAttachmentItem(String fileName, String status) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const Icon(Icons.image),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() {
              attachments.removeWhere((element) => element['name'] == fileName);
              developer.log('Attachment removed: $fileName');
              developer.log('Attachments array after removing: $attachments');
            });
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
