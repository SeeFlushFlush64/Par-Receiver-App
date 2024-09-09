import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/square_tile.dart';
import 'package:modernlogintute/pages/forgotpasswordpage.dart';
import 'package:modernlogintute/services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onTap,
  });
  final Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  // final user = FirebaseAuth.instance.currentUser!;
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  // void inputData() {
  //   final User? user = auth.currentUser;
  //   final uid = user?.uid;
  //   currentUID = uid!;
  // }
  // sign user in method
  void signUserIn() async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Validate form
    if (_formKey.currentState!.validate()) {
      try {
        // Perform login
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(), // Trim whitespace
          password: passwordController.text,
        );

        // Check if the email matches exactly (case-sensitive)
        if (userCredential.user?.email == emailController.text) {
          Navigator.of(context).pop(); // Close loading dialog
          validLogInCredentials(emailController.text);
        } else {
          Navigator.of(context).pop(); // Close loading dialog
          invalidLogInCredentials(); // Show invalid login credentials message
        }
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        if (e.code == 'wrong-password' ||
            e.code == 'user-not-found' ||
            e.code == 'INVALID_LOGIN_CREDENTIALS') {
          invalidLogInCredentials(); // Show invalid login credentials message
        } else {
          print("Error: ${e.code}");
          // Handle other potential FirebaseAuth errors here
        }
      }
    } else {
      Navigator.of(context).pop(); // Close loading dialog if validation fails
    }
  }

  void validLogInCredentials(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Log in as ${email}',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void invalidLogInCredentials() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invalid email or password',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(height: 50),

                  // logo
                  // const Icon(
                  //   Icons.shopping_cart_checkout_outlined,
                  //   size: 100,
                  //   color: Color(0xFF191970),
                  // ),
                  Lottie.asset('lib/images/nahuhulog na parcel.json',
                      height: 250.0, width: 250.0),

                  // const SizedBox(height: 50),

                  // welcome back, you've been missed!
                  Text(
                    'Parcel Incoming? No worries!',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 18.0,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      // Use a regular expression to check if the entered email is alphanumeric
                      if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                          .hasMatch(value)) {
                        return 'Enter a valid alphanumeric email address';
                      }
                      // Check if the email ends with '@gmail.com'
                      if (!value.endsWith('@gmail.com')) {
                        return 'Email must end with @gmail.com';
                      }
                      return null;
                    },
                    suffixIcon: null,
                    leadingIcon: Icon(
                      Icons.email,
                      color: Color(0xFF191970),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: _obscurePassword,
                    leadingIcon: Icon(
                      Icons.lock,
                      color: Color(0xFF191970),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      // Add additional password validation logic here if needed
                      return null;
                    },
                    suffixIcon: IconButton(
                      color: Color(0xFF191970),
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    //               onTogglePasswordVisibility: () {
                    // //
                    //               setState(() {
                    //                 obscureText = !obscureText;
                    //               });
                    //               },
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  InkWell(
                    child: MyButton(
                      horizontalDimension: 25.0,
                      verticalDimension: 25.0,
                      text: "Sign In",
                      onTap: signUserIn,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: GoogleFonts.ubuntu(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // google + apple sign in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      SquareTile(
                          onTap: () async {
                            CircularProgressIndicator();
                            AuthService().signInWithGoogle();
                          },
                          imagePath: 'lib/images/google.png'),

                      // SizedBox(width: 25),

                      // // apple button
                      // SquareTile(
                      //     onTap: () {
                      //       CircularProgressIndicator();
                      //     },
                      //     imagePath: 'lib/images/phone-call.png'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: GoogleFonts.ubuntu(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: widget.onTap,
                        child: Text(
                          'Register now',
                          style: GoogleFonts.ubuntu(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // void _onSubmit() {
  //   // Implement your login logic or other actions here
  //   String email = _emailController.text;
  //   String password = _passwordController.text;

  //   // Print the email and password for demonstration purposes
  //   print('Email: $email');
  //   print('Password: $password');
  // }
}
