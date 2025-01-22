import 'package:splitwise/Models/GroupModel.dart';

class ExpenseModel {
  String? expenseId;
  ExpenseDetails? expenseDetails;

  ExpenseModel({this.expenseId, this.expenseDetails});

  ExpenseModel.fromJson(Map<String, dynamic> json) {
    expenseId = json['_id'];
    expenseDetails = json['expenseDetails'] != null
        ? ExpenseDetails.fromJson(json['expenseDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = expenseId;
    if (expenseDetails != null) {
      data['expenseDetails'] = expenseDetails!.toJson();
    }
    return data;
  }
}

class ExpenseDetails {
  String? expenseId;
  String? description;
  double? amount;
  List<Members>? paidBy;
  List<Members>? splitAmong;
  String? splitType;
  String? createdAt;

  ExpenseDetails({
    this.expenseId,
    this.description,
    this.amount,
    this.paidBy,
    this.splitAmong,
    this.splitType,
    this.createdAt,
  });

  ExpenseDetails.fromJson(Map<String, dynamic> json) {
    expenseId = json['_id'];
    description = json['description'];
    amount = (json['amount'] ?? 0).toDouble();
    if (json['paidBy'] != null) {
      paidBy = <Members>[];
      json['paidBy'].forEach((v) {
        paidBy!.add(Members.fromJson(v));
      });
    }
    if (json['splitAmong'] != null) {
      splitAmong = <Members>[];
      json['splitAmong'].forEach((v) {
        splitAmong!.add(Members.fromJson(v));
      });
    }
    splitType = json['splitType'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = expenseId;
    data['description'] = description;
    data['amount'] = amount;
    if (paidBy != null) {
      data['paidBy'] = paidBy!.map((v) => v.toJson()).toList();
    }
    if (splitAmong != null) {
      data['splitAmong'] = splitAmong!.map((v) => v.toJson()).toList();
    }
    data['splitType'] = splitType;
    data['createdAt'] = createdAt;
    return data;
  }
}
