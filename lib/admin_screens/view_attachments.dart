import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewAttachments extends StatefulWidget {
  final String docType;
  final String docNo;

  ViewAttachments({required this.docType, required this.docNo});

  @override
  _ViewAttachmentsState createState() => _ViewAttachmentsState();
}

class _ViewAttachmentsState extends State<ViewAttachments> {
  late Future<List<Attachment>> _attachmentsFuture;

  @override
  void initState() {
    super.initState();
    _attachmentsFuture = _fetchAttachments();
  }

  Future<List<Attachment>> _fetchAttachments() async {
    try {
      var url = Uri.parse(
          'http://127.0.0.1/localconnect/view_attachment.php?doc_type=${widget.docType}&doc_no=${widget.docNo}');
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
                    title: Text(attachments[index].fileName),
                    subtitle: Text(attachments[index].filePath),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Attachment {
  final String fileName;
  final String filePath;

  Attachment({required this.fileName, required this.filePath});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['file_name'],
      filePath: json['file_path'],
    );
  }
}
