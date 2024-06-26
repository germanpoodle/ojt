class DisbursementDetails {
  final String id;
  final String transactingParty;
  final String docType;
  final String docNo;
  final String transactionStatus;
  final String checkAmount;
  final String remarks;
  final String transTypeDescription;

  DisbursementDetails({
    required this.id,
    required this.transactingParty,
    required this.docType,
    required this.docNo,
    required this.transactionStatus,
    required this.checkAmount,
    required this.remarks,
    required this.transTypeDescription,
  });

  factory DisbursementDetails.fromJson(Map<String, dynamic> json) {
    return DisbursementDetails(
      id: json['id'] ?? '',
      transactingParty: json['transactingParty'] ?? '',
      docType: json['docType'] ?? '',
      docNo: json['docNo'] ?? '',
      transactionStatus: json['transactionStatus'] ?? '',
      checkAmount: json['checkAmount'] ?? '',
      remarks: json['remarks'] ?? '',
      transTypeDescription: json['transTypeDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactingParty': transactingParty,
      'docType': docType,
      'docNo': docNo,
      'transactionStatus': transactionStatus,
      'checkAmount': checkAmount,
      'remarks': remarks,
      'transTypeDescription': transTypeDescription,
    };
  }
}
