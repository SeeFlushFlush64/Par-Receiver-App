import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/adminTabs/adminHome.dart';
import 'package:modernlogintute/pages/machine_status.dart';
import 'package:modernlogintute/userTabs/home.dart';
import 'package:modernlogintute/pages/home_page.dart';
import 'package:modernlogintute/adminTabs/adminBotNavController.dart';
import 'package:modernlogintute/userTabs/botNavController.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
  }

  @override
  void initState() {
    super.initState();

    //user needs to be created before
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      Timer.periodic(Duration(seconds: 3), (_) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    inputData();
    return isEmailVerified
        ? (currentUID == '52ihU8Gw6EbJbd38PYwCnwurj363'
            ? AdminBotNavController()
            : BotNavController())
        : Scaffold(
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Verifying your email address. Kindly check your inbox.',
                    style: GoogleFonts.ubuntu(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
