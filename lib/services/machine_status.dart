// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

MachineStatusDetails machineStatusDetailsFromJson(String str) =>
    MachineStatusDetails.fromJson(json.decode(str));

String machineStatusDetailsToJson(MachineStatusDetails data) =>
    json.encode(data.toJson());

class MachineStatusDetails {
  String? id;
  final bool online;

  MachineStatusDetails({
    required this.online,
  });

  factory MachineStatusDetails.fromJson(Map<String, dynamic> json) =>
      MachineStatusDetails(
        online: json["Online"],
      );

  Map<String, dynamic> toJson() => {
        "Online": online,
      };
}
