class Attachment {
  final String fileName;
  final String filePath;
  final String? status;

  Attachment({
    required this.fileName,
    required this.filePath,
    this.status,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['file_name'],
      filePath: json['file_path'],
      status: json['status'],
    );
  }
}