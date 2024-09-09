// To parse this JSON data, do
//
//     final Terminated = TerminatedFromJson(jsonString);

import 'dart:convert';

TerminatedDetails terminatedDetailsFromJson(String str) =>
    TerminatedDetails.fromJson(json.decode(str));

String terminatedDetailsToJson(TerminatedDetails data) =>
    json.encode(data.toJson());

class TerminatedDetails {
  final String modeOfPayment;
  final String time;
  final String date;
  String? cashContainer;
  bool unread;
  String? id;
  final String productName;
  final String trackingId;
  final String uid;

  TerminatedDetails({
    required this.unread,
    required this.modeOfPayment,
    required this.productName,
    required this.trackingId,
    required this.uid,
    required this.date,
    required this.time,
  });

  factory TerminatedDetails.fromJson(Map<String, dynamic> json) =>
      TerminatedDetails(
        modeOfPayment: json["Mode of Payment"],
        productName: json["Product Name"],
        trackingId: json["Tracking ID"],
        date: json["Date"],
        time: json["Time"],
        uid: json["UID"],
        unread: json["Unread"],
      );

  Map<String, dynamic> toJson() => {
        "Mode of Payment": modeOfPayment,
        "Product Name": productName,
        "Tracking ID": trackingId,
        "Unread": unread,
        "UID": uid,
        "Time": time,
        "Date": date,
      };
}
