// To parse this JSON data, do
//
//     final received = receivedFromJson(jsonString);

import 'dart:convert';

DeviceTokens deviceTokensFromJson(String str) =>
    DeviceTokens.fromJson(json.decode(str));

String deviceTokensToJson(DeviceTokens data) =>
    json.encode(data.toJson());

class DeviceTokens {
  String? id;
  final String deviceToken;

  DeviceTokens({
    required this.deviceToken,
  });

  factory DeviceTokens.fromJson(Map<String, dynamic> json) =>
      DeviceTokens(
        deviceToken: json["Device Token"],
      );

  Map<String, dynamic> toJson() => {
        "Device Token": deviceToken,
      };
}
