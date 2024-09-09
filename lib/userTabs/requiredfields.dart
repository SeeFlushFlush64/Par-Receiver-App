// To parse this JSON data, do
//
//     final parcels = parcelsFromJson(jsonString);

import 'dart:convert';

Parcels parcelsFromJson(String str) => Parcels.fromJson(json.decode(str));

String parcelsToJson(Parcels data) => json.encode(data.toJson());

class Parcels {
  final String modeOfPayment;
  String? timeReceived;
  int? ordering;
  String? cashContainer;
  bool? delivered;
  String? docUID;
  String? id;
  double? price;
  final String productName;
  final String trackingId;
  final String dateAdded;
  final String timeAdded;
  final String uid;

  Parcels({
    required this.timeAdded,
    required this.dateAdded,
    required this.modeOfPayment,
    this.cashContainer,
    this.ordering,
    this.delivered,
    this.price,
    this.timeReceived,
    required this.productName,
    required this.trackingId,
    required this.uid,
    // this.docUID,
  });

  factory Parcels.fromJson(Map<String, dynamic> json) => Parcels(
        modeOfPayment: json["Mode of Payment"],
        ordering: json["Ordering"],
        price: json["Price"],
        productName: json["Product Name"],
        trackingId: json["Tracking ID"],
        cashContainer: json["Cash Container"],
        delivered: json["Delivered"],
        dateAdded: json['Date Added'],
        timeAdded: json['Time Added'],
        timeReceived: json['Time Received'],
        uid: json['UID'],
      );

  Map<String, dynamic> toJson() => {
        "Mode of Payment": modeOfPayment,
        "Ordering": ordering,
        "Price": price,
        "Product Name": productName,
        "Cash Container": cashContainer,
        "Tracking ID": trackingId,
        "Delivered": delivered,
        "Date Added": dateAdded,
        "Time Added": timeAdded,
        "Time Received": timeReceived,
        "UID": uid,
      };
}
