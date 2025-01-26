// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Paymentmodel {
  final String receiverName;
  final String revicerUpiId;
  final String amout;
  final String groupId;
  final String expenseId;

  Paymentmodel(
      {required this.receiverName,
      required this.revicerUpiId,
      required this.groupId,
      required this.expenseId,
      required this.amout});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'receiverName': receiverName,
      'revicerUpiId': revicerUpiId,
      'groupId': groupId,
      'expenseId': expenseId,
      'amout': amout,
    };
  }

  factory Paymentmodel.fromMap(Map<String, dynamic> map) {
    return Paymentmodel(
      expenseId: map['expenseId'] as String,
      groupId: map['groupId'] as String,
      receiverName: map['receiverName'] as String,
      revicerUpiId: map['revicerUpiId'] as String,
      amout: map['amout'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Paymentmodel.fromJson(String source) =>
      Paymentmodel.fromMap(json.decode(source) as Map<String, dynamic>);
}
