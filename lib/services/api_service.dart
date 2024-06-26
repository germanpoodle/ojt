import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_transaction.dart';

Future<List<Transaction>> fetchTransactions() async {
  final response = await http.get(Uri.parse('http://http://http://127.0.0.1/localconnect/get_transaction.php'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Transaction.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load transactions');
  }
}
