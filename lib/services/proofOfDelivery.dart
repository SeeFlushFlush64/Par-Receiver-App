// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

ProofOfDelivery proofOfDeliveryFromJson(String str) => ProofOfDelivery.fromJson(json.decode(str));

String proofOfDeliveryToJson(ProofOfDelivery data) => json.encode(data.toJson());

class ProofOfDelivery {
  // final String modeOfPayment;
  final String parcelPic;
  // final String dateAdded;
  // int? ordering;
  // String? cashContainer;
  // bool? delivered;
  // String? docUID;
  String? id;
  // String? addOrReceived;
  // double? price;
  // final String productName;
  final String trackingId;
  // final String dateAdded;
  // final String timeAdded;

  ProofOfDelivery({
    required this.parcelPic,
    // required this.timeAdded,
    // required this.dateAdded,
    // required this.modeOfPayment,
    // this.cashContainer,
    // this.ordering,
    // this.delivered,
    // this.price,
    // required this.addOrReceived,
    // required this.productName,
    required this.trackingId,
    // this.docUID,
  });

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) => ProofOfDelivery(
      // modeOfPayment: json["Mode of Payment"],
      // addOrReceived: json["Add or Received"],
      // ordering: json["Ordering"],
      // price: json["Price"],
      // productName: json["Product Name"],
      // dateAdded: json['Date Added'],
      // timeAdded: json['Time Added'],
      parcelPic: json["ParcelPic"],
      trackingId: json["Tracking ID"]);
  // cashContainer: json["Cash Container"],
  // delivered: json["Delivered"],

  Map<String, dynamic> toJson() => {
        "Parcel Pic": parcelPic,
        // "Mode of Payment": modeOfPayment,
        // "Ordering": ordering,
        // "Price": price,
        // "Add or Received": addOrReceived,
        // "Product Name": productName,
        // "Cash Container": cashContainer,
        "Tracking ID": trackingId,
        // "Delivered": delivered,
        // "Date Added": dateAdded,
        // "Time Added": timeAdded,
      };
}
