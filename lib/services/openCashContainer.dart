// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

OpenCashContainer openCashContainerFromJson(String str) =>
    OpenCashContainer.fromJson(json.decode(str));

String openCashContainerToJson(OpenCashContainer data) =>
    json.encode(data.toJson());

class OpenCashContainer {
  final String cashContainer;
  final String status;
  String? id;
  OpenCashContainer({
    required this.cashContainer,
    required this.status,
  });

  factory OpenCashContainer.fromJson(Map<String, dynamic> json) =>
      OpenCashContainer(
        cashContainer: json["Cash Container"],
        status: json["Status"],
      );
  Map<String, dynamic> toJson() => {
        "Cash Container": cashContainer,
        "Status": status,
      };
}
