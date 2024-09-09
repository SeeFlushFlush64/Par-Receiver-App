// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

StoredDetails storedDetailsFromJson(String str) =>
    StoredDetails.fromJson(json.decode(str));

String storedDetailsToJson(StoredDetails data) =>
    json.encode(data.toJson());

class StoredDetails {
  final String modeOfPayment;
  // final String timeAdded;
  final String dateAdded;
  final String timeReceived;
  final String dateReceived;
  // int? ordering;
  String? cashContainer;
  // bool? delivered;
  // String? docUID;
  bool unread;
  String? id;
  String? addOrReceived;
  double? price;
  final String productName;
  final String trackingId;
  final String uid;
  // final String dateAdded;
  // final String timeAdded;

  StoredDetails({
    required this.unread,
    required this.dateAdded,
    required this.modeOfPayment,
    
    // this.ordering,
    // this.delivered,
    this.price,
    required this.addOrReceived,
    required this.productName,
    required this.trackingId,
    required this.uid,
    required this.dateReceived,
    required this.timeReceived,
    // this.docUID,
  });

  factory StoredDetails.fromJson(Map<String, dynamic> json) =>
      StoredDetails(
        modeOfPayment: json["Mode of Payment"],
        addOrReceived: json["Add or Received"],
        // ordering: json["Ordering"],
        price: json["Price"],
        productName: json["Product Name"],
        dateAdded: json['Date Added'],
        // timeAdded: json['Time Added'],
        trackingId: json["Tracking ID"],
        // cashContainer: json["Cash Container"],
        dateReceived: json["Date Received"],
        timeReceived: json["Time Received"],
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
        // "Time Added": timeAdded,
        "Unread": unread,
        "UID": uid,
        "Time Received": timeReceived,
        "Date Received": dateReceived,
      };
}
