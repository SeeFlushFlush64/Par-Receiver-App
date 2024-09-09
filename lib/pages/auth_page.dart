import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/count%20page/codOrdersNungCurrentUser.dart';
import 'package:modernlogintute/pages/home_page.dart';
import 'package:modernlogintute/pages/login_or_register.dart';
import 'package:modernlogintute/pages/userName.dart';
import 'package:modernlogintute/services/verifyemailpage.dart';
// import 'package:modernlogintute/trial/item_list.dart';

// String currentUID = "";
// final FirebaseAuth auth = FirebaseAuth.instance;

// void inputData() {
//   final User? user = auth.currentUser;
//   final uid = user?.uid;
//   currentUID = uid!;
//   // print(currentUID);
//   // here you write the codes to input the data into firestore
// }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // inputData();
          if (snapshot.hasData) {
            // return UserName();
            return VerifyEmailPage();
            // return CODOrdersNungCurrentUser();
            // return ItemList();
          } else {
            
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}
