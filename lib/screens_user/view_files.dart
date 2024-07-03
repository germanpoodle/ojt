import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../admin_screens/notifications.dart';

class ViewFilesPage extends StatefulWidget {
  final List<Map<String, String>> attachments;
  final Function(int index) onDelete;
  final String docType;
  final String docNo;

  const ViewFilesPage({
    Key? key,
    required this.attachments,
    required this.onDelete,
    required this.docType,
    required this.docNo,
  }) : super(key: key);

  @override
  _ViewFilesPageState createState() => _ViewFilesPageState();
}

class _ViewFilesPageState extends State<ViewFilesPage> {
  List<Map<String, String>> _attachments = [];

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.attachments);
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
    widget.onDelete(index); // Call the callback function
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      String fullPath = "${dir.path}/$fileName";
      Dio dio = Dio();
      await dio.download(fileUrl, fullPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  Future<String> _loadAsset(String path) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$path');
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw Exception('Asset not found at $path');
      }
    } catch (e) {
      throw Exception('Failed to load asset: $e');
    }
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
      body: ListView.builder(
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return Dismissible(
            key: Key(attachment["name"]!),
            onDismissed: (direction) {
              _removeAttachment(index);
            },
            background: Container(
              color: Colors.red,
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        attachment['name']!.toLowerCase().endsWith('.jpeg') ||
                        attachment['name']!.toLowerCase().endsWith('.jpg') ||
                        attachment['name']!.toLowerCase().endsWith('.png')
                            ? Image.network(
                                'http://192.168.68.119/localconnect/assets/${attachment['path']}',
                                width: screenSize.width * 0.75,
                                height: screenSize.height * 0.3,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                color: Colors.grey,
                                child: Center(child: Text('File')),
                              ),
                        Text(attachment['status']!),
                      ],
                    ),
                  ),
                  if (attachment['status'] == 'Uploaded')
                    GestureDetector(
                      onTap: () async {
                        final imagePath = attachment['path'];
                        final imageData = await _loadAsset(imagePath!);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Image'),
                              content: Image.memory(base64Decode(imageData)),
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.remove_red_eye),
                    ),
                  IconButton(
                    icon: Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      _downloadFile(
                        'http://192.168.68.119/localconnect/assets/${attachment['path']}',
                        attachment['name']!,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}