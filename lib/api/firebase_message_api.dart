import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:modernlogintute/userTabs/device_tokens.dart';

class FirebaseMessagingApi {
  // String currentUID = "";
  // final FirebaseAuth auth = FirebaseAuth.instance;
  // void inputData() {
  //   final User? user = auth.currentUser;
  //   final uid = user?.uid;
  //   currentUID = uid!;
  // }
  
  final _firebaseMessaging = FirebaseMessaging.instance;
  String userDeviceToken = "";
  Future<void> initNotifications() async {
    // inputData();
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    // userDeviceToken = fCMToken != null ? fCMToken : "";
    // DeviceTokens deviceTokens = DeviceTokens(
    //   deviceToken: userDeviceToken,
    // );
    // final deviceTokensRef = FirebaseFirestore.instance
    //     .collection('deviceTokens')
    //     .doc(currentUID);
    // deviceTokens.id = deviceTokensRef.id;
    // final add = deviceTokens.toJson();
    // await deviceTokensRef.set(add).whenComplete(() => null);
    print("Token: $fCMToken");
  }
}
