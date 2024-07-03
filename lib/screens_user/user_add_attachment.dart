import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../models/user_transaction.dart';
import 'no_support.dart';
import 'transmitter_homepage.dart';
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
  List<Map<String, dynamic>> attachments = [];
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

  Future<void> _pickFile() async {
    developer.log('Picking file...');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (var file in result.files) {
          _fileName = file.name ?? 'Unknown';
          attachments.add({
            'name': _fileName!,
            'status': 'Selected',
            'bytes': file.bytes,
            'size': file.size,
          });
        }
        //  developer.log('Attachments array after adding: $attachments');
      });
      developer.log('Files picked: ${result.files.length}');
    } else {
      developer.log('File picking cancelled');
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 128, 189),
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
                      // Handle notifications button tap
                    },
                    icon: const Icon(
                      Icons.notifications,
                      size: 24,
                      color: Color.fromARGB(255, 233, 227, 227),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Handle user profile button tap
                  },
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
                    if (attachment['name'] != null &&
                        attachment['bytes'] != null &&
                        attachment['size'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: _buildAttachmentItem(
                          attachment['name'],
                          attachment['status'],
                        ),
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
                          onPressed: () {
                            List<Map<String, String>> attachmentsString =
                                attachments
                                    .map((attachment) => attachment.map(
                                          (key, value) =>
                                              MapEntry(key, value.toString()),
                                        ))
                                    .toList();

                            for (var attachment in attachmentsString) {
                              if (attachment['name'] == null ||
                                  attachment['name']!.isEmpty) {
                                developer.log(
                                    'Error: attachment name is null or empty');
                                return;
                              }

                              if (attachment['bytes'] == null) {
                                developer
                                    .log('Error: attachment bytes are null');
                                return;
                              }

                              if (attachment['size'] == null ||
                                  attachment['size']!.isEmpty ||
                                  int.parse(attachment['size']!) <= 0) {
                                developer.log(
                                    'Error: attachment size is null or invalid');
                                return;
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserSendAttachment(
                                  transaction: widget.transaction,
                                  selectedDetails: [],
                                  attachments: attachmentsString,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 79, 129, 189),
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
        selectedItemColor: const Color.fromARGB(255, 79, 128, 189),
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

  Widget _buildAttachmentItem(String? fileName, String? status) {
    if (fileName == null || status == null) return Container();

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
