import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password Reset Link")));
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text('Enter your email to reset your password'),
          // SizedBox(
          //   height: 20.0,
          // ),
          const SizedBox(height: 50),

          // logo
          const Icon(
            Icons.email_outlined,
            size: 100,
            color: Color(0xFF191970),
          ),

          const SizedBox(height: 50),

          // welcome back, you've been missed!
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Enter your email to reset your password',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 25),
          // email textfield
          MyTextField(
            controller: emailController,
            hintText: 'Email Address',
            obscureText: false,
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter an email address';
            //   }
            //   // Use a regular expression to check if the entered email is alphanumeric
            //   if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
            //       .hasMatch(value)) {
            //     return 'Enter a valid alphanumeric email address';
            //   }
            //   // Check if the email ends with '@gmail.com'
            //   if (!value.endsWith('@gmail.com')) {
            //     return 'Email must end with @gmail.com';
            //   }
            //   return null;
            // },
            suffixIcon: null,
            leadingIcon: Icon(
              Icons.email,
              color: Color(0xFF191970),
            ),
          ),
          const SizedBox(height: 25),

          // sign in button
          InkWell(
            child: MyButton(
              horizontalDimension: 25.0,
              verticalDimension: 16.0,
              text: "Send Reset Link",
              onTap: passwordReset,
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
