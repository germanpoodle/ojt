import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../models/attachment.dart';

class TransViewAttachments extends StatefulWidget {
  final String docType;
  final String docNo;

  TransViewAttachments({
    Key? key,
    required this.docType,
    required this.docNo,
  }) : super(key: key);

  @override
  _TransViewAttachmentsState createState() => _TransViewAttachmentsState();
}

class _TransViewAttachmentsState extends State<TransViewAttachments> {
  late Future<List<Attachment>> _attachmentsFuture;

  @override
  void initState() {
    super.initState();
    _attachmentsFuture = _fetchAttachments();
  }

  Future<List<Attachment>> _fetchAttachments() async {
    try {
      var url = Uri.parse(
          'http://192.168.68.119/localconnect/view_attachment.php?doc_type=${widget.docType}&doc_no=${widget.docNo}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((attachment) => Attachment.fromJson(attachment))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load attachments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch attachments: $e');
    }
  }

  Future<String> _loadAsset(String assetPath) async {
    // Construct the local file path for the asset
    final filePath = '/Applications/XAMPP/xamppfiles/htdocs/localconnect/assets/$assetPath';

    if (File(filePath).existsSync()) {
      final file = File(filePath);
      return file.readAsString();
    } else {
      throw Exception('Asset not found at $filePath');
    }
  }

  Widget _buildAttachmentWidget(Attachment attachment) {
    String fileName = attachment.fileName.toLowerCase();
    if (fileName.endsWith('.jpeg') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.png')) {
      // Use Image.asset for local assets
      return Image.asset(
        '/localconnect/assets/${attachment.filePath}',
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.62,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Error loading image: $error'));
        },
      );
    } else if (fileName.endsWith('.pdf')) {
      return FutureBuilder(
        future: _getPdfFile(attachment.filePath),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.52,
              child: PDFView(
                filePath: snapshot.data!,
                autoSpacing: true,
                pageFling: true,
                pageSnap: true,
                swipeHorizontal: true,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading PDF: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return Center(child: Text('Unsupported file type'));
    }
  }

  Future<String> _getPdfFile(String filePath) async {
    try {
      final response = await http.get(Uri.parse(filePath));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${filePath.split('/').last}');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  void _showAttachmentDetails(String fileName, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: _buildAttachmentWidget(
                  Attachment(fileName: fileName, filePath: filePath),
                ),
              ),
              ElevatedButton(
                onPressed: () => _downloadFile(filePath, fileName),
                child: Text('Download'),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 9, 41, 145),
        toolbarHeight: 77,
        title: Text(
          'Attachments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Attachment>>(
            future: _attachmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No attachments found!'));
              } else {
                var attachments = snapshot.data!;
                return ListView.builder(
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.attach_file),
                        title: Text(attachments[index].fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attachments[index].fileName),
                            Text(attachments[index].status ?? 'No Status'),
                          ],
                        ),
                        trailing: attachments[index].status == 'Uploaded'
                            ? GestureDetector(
                                onTap: () async {
                                  final imagePath = attachments[index].filePath;
                                  final imageData = await _loadAsset(imagePath);
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
                              )
                            : null,
                        onTap: () => _showAttachmentDetails(
                          attachments[index].fileName,
                          attachments[index].filePath,
                        ),
                      ),
                    );
                  },
                );
              }
            },
      )
    );
  }
}

