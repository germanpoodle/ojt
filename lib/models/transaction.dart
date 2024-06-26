// class Transaction {
//   final String transactingParty;
//   final String transDate;
//   final String checkNo;
//   final String docType;
//   final String docNo;
//   final String checkBankDrawee;

//   Transaction({
//     required this.transactingParty,
//     required this.transDate,
//     required this.checkNo,
//     required this.docType,
//     required this.docNo,
//     required this.checkBankDrawee,
//   });

//   factory Transaction.fromJson(Map<String, dynamic> json) {
//     return Transaction(
//       transactingParty: json['transacting_party'] ?? '',
//       transDate: json['check_date'] ?? '', 
//       checkNo: json['check_no'] ?? '',
//       docType: json['doc_type'] ?? '',
//       docNo: json['doc_no'] ?? '',
//       checkBankDrawee: json['check_drawee_bank'] ?? '',
//     );
//   }
// }
