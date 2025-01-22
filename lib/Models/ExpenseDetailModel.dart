import 'package:splitwise/Models/GroupModel.dart';

class ExpenceSplitModel {
  String? expenseId;
  String? groupId;
  String? description;
  int? amount;
  List<Members>? paidBy;
  List<Members>? splitAmong;
  String? splitType;
  List<DetailedSplit>? detailedSplit;
  String? createdAt;
  String? updatedAt;

  ExpenceSplitModel({
    this.expenseId,
    this.groupId,
    this.description,
    this.amount,
    this.paidBy,
    this.splitAmong,
    this.splitType,
    this.detailedSplit,
    this.createdAt,
    this.updatedAt,
  });

  ExpenceSplitModel.fromJson(Map<String, dynamic> json) {
    expenseId = json['_id'];
    groupId = json['groupId'];
    description = json['description'];
    amount = json['amount'];
    if (json['paidBy'] != null) {
      paidBy = <Members>[];
      json['paidBy'].forEach((v) {
        paidBy!.add(new Members.fromJson(v));
      });
    }
    if (json['splitAmong'] != null) {
      splitAmong = <Members>[];
      json['splitAmong'].forEach((v) {
        splitAmong!.add(new Members.fromJson(v));
      });
    }
    splitType = json['splitType'];
    if (json['detailedSplit'] != null) {
      detailedSplit = <DetailedSplit>[];
      json['detailedSplit'].forEach((v) {
        detailedSplit!.add(new DetailedSplit.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.expenseId;
    data['groupId'] = this.groupId;
    data['description'] = this.description;
    data['amount'] = this.amount;
    if (this.paidBy != null) {
      data['paidBy'] = this.paidBy!.map((v) => v.toJson()).toList();
    }
    if (this.splitAmong != null) {
      data['splitAmong'] = this.splitAmong!.map((v) => v.toJson()).toList();
    }
    data['splitType'] = this.splitType;
    if (this.detailedSplit != null) {
      data['detailedSplit'] =
          this.detailedSplit!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}

class DetailedSplit {
  String? from;
  String? to;
  int? amount;

  DetailedSplit({this.from, this.to, this.amount});

  DetailedSplit.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['amount'] = this.amount;
    return data;
  }
}
