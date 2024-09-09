// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

AddedDetails addedDetailsFromJson(String str) =>
    AddedDetails.fromJson(json.decode(str));

String addedDetailsToJson(AddedDetails data) => json.encode(data.toJson());

class AddedDetails {
  final String modeOfPayment;
  final String timeAdded;
  final String dateAdded;
  bool unread;
  // int? ordering;
  String? cashContainer;
  // bool? delivered;
  // String? docUID;
  String? id;
  String? addOrReceived;
  double? price;
  final String productName;
  final String trackingId;
  final String uid;
  // final String dateAdded;
  // final String timeAdded;

  AddedDetails({
    required this.timeAdded,
    required this.dateAdded,
    required this.modeOfPayment,
    required this.unread,
    this.cashContainer,
    // this.ordering,
    // this.delivered,
    this.price,
    required this.addOrReceived,
    required this.productName,
    required this.trackingId,
    required this.uid,
    // this.docUID,
  });

  factory AddedDetails.fromJson(Map<String, dynamic> json) => AddedDetails(
        modeOfPayment: json["Mode of Payment"],
        addOrReceived: json["Add or Received"],
        // ordering: json["Ordering"],
        price: json["Price"],
        productName: json["Product Name"],
        dateAdded: json['Date Added'],
        timeAdded: json['Time Added'],
        trackingId: json["Tracking ID"],
        cashContainer: json["Cash Container"],
        uid: json["UID"],
        unread: json["Unread"],
      );
  // delivered: json["Delivered"],

  Map<String, dynamic> toJson() => {
        "Mode of Payment": modeOfPayment,
        // "Ordering": ordering,
        "Price": price,
        "Add or Received": addOrReceived,
        "Product Name": productName,
        "Cash Container": cashContainer,
        "Tracking ID": trackingId,
        // "Delivered": delivered,
        "Date Added": dateAdded,
        "Time Added": timeAdded,
        "UID": uid,
        "Unread":unread,
      };
}
