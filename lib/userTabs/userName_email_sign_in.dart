// To parse this JSON data, do
//
//     final parcels = parcelsFromJson(jsonString);

import 'dart:convert';

UserNameEmailSignIn userNameEmailSignInFromJson(String str) =>
    UserNameEmailSignIn.fromJson(json.decode(str));

String userNameEmailSignInToJson(UserNameEmailSignIn data) =>
    json.encode(data.toJson());

class UserNameEmailSignIn {
  String? id;
  int? codLimits;
  int? nonCodLimits;
  String? signInWith;
  final String name;
  final String uid;

  UserNameEmailSignIn({
    required this.name,
    required this.uid,
    this.signInWith,
    this.codLimits,
    this.nonCodLimits,
  });

  factory UserNameEmailSignIn.fromJson(Map<String, dynamic> json) =>
      UserNameEmailSignIn(
        name: json["Name"],
        uid: json['UID'],
        codLimits: json["COD Limits"],
        nonCodLimits: json["Non-COD Limits"],
        signInWith: json["Sign in With"]
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "UID": uid,
        "COD Limits": codLimits,
        "Non-COD Limits": nonCodLimits,
        "Sign in With":signInWith,
      };
}
