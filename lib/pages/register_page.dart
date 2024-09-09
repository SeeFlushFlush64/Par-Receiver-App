import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/square_tile.dart';
import 'package:modernlogintute/pages/login_or_register.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:modernlogintute/pages/machine_status.dart';
import 'package:modernlogintute/services/auth_services.dart';
import 'package:modernlogintute/userTabs/userName_email_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onTap,
  });
  final Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showPassword = false; // Variable to toggle visibility
  bool showConfirmPassword = false; // Variable to toggle visibility
  final _formKey = GlobalKey<FormState>();
  late String name;
  // text editing controllers
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    // print(currentUID);
    // here you write the codes to input the data into firestore
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {
    setState(() {
      name = nameController.text;

      log(name);
    });

    // show loading circle

    showDialog(
      context: context,
      builder: (context) {
        // Schedule a function to close the dialog after a delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (_formKey.currentState!.validate()) {
      // Validation successful, perform login or other actions
    }
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage("Passwords do not match");
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, // Convert email to lowercase
        password: passwordController.text,
      );
      // Navigator.pop(context);
      inputData();
      log(currentUID);
      UserNameEmailSignIn userNameEmailSignIn = UserNameEmailSignIn(
        name: name,
        uid: currentUID,
        codLimits: 4,
        nonCodLimits: 8,
        signInWith: "Email",
      );
      final userNameEmailSignInRef = FirebaseFirestore.instance
          .collection('userName_email_sign_in')
          .doc(currentUID);
      userNameEmailSignIn.id = userNameEmailSignInRef.id;
      final userName = userNameEmailSignIn.toJson();
      await userNameEmailSignInRef.set(userName).whenComplete(() => null);
      Navigator.pop(context);
      // final userCredential =
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.code);
      Navigator.pop(context);
    }

    // Check if the email matches exactly (case-sensitive) in your database
    //   if (userCredential.user?.email == emailController.text) {
    //     Navigator.pop(context);
    //   } else {
    //     // Display an error message
    //     invalidLogInCredentials();
    //   }

    // print("error code here ${e.code}");
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
            ),
          ),
        );
      },
    );
  }

  final nameController = TextEditingController();
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
                  Lottie.asset('lib/images/receiving_logo.json',
                      height: 200.0, width: 200.0),

                  // welcome back, you've been missed!
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Let\'s create your Par-Receiver account',
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                    controller: nameController,
                    hintText: 'Name',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is left blank';
                      }
                      // Use a regular expression to check if the entered email is alphanumeric
                      if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                        return 'Enter a valid name';
                      }

                      return null;
                    },
                    suffixIcon: null,
                    leadingIcon: Icon(
                      Icons.person,
                      color: Color(0xFF191970),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    suffixIcon: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is left blank';
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
                    leadingIcon: Icon(
                      Icons.email,
                      color: Color(0xFF191970),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    leadingIcon: Icon(
                      Icons.lock,
                      color: Color(0xFF191970),
                    ),
                    hintText: 'Password',
                    obscureText: !showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is left blank';
                      }

                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFF191970),
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // confirm password textfield
                  MyTextField(
                    controller: confirmPasswordController,
                    leadingIcon: Icon(
                      Icons.lock,
                      color: Color(0xFF191970),
                    ),
                    hintText: 'Confirm Password',
                    obscureText: !showConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is left blank';
                      }

                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF191970),
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Text(
                  //         'Forgot Password?',
                  //         style: TextStyle(color: Colors.grey[600]),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 25),

                  // sign in button
                  InkWell(
                    child: MyButton(
                      horizontalDimension: 25.0,
                      verticalDimension: 25.0,
                      text: "Sign Up",
                      onTap: signUserUp,
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
                          onTap: () => AuthService().signInWithGoogle(),
                          imagePath: 'lib/images/google.png'),

                      // SizedBox(width: 25),

                      // // apple button
                      // SquareTile(
                      //     onTap: () {
                      //       CircularProgressIndicator();
                      //     },
                      //     imagePath: 'lib/images/phone-call.png')
                    ],
                  ),

                  const SizedBox(height: 30),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.ubuntu(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login now',
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
}

// class Navbar extends StatefulWidget {
//   Navbar({Key? key}) : super(key: key);

//   @override
//   State<Navbar> createState() => _NavbarState();
// }

// class _NavbarState extends State<Navbar> {
//   final user = FirebaseAuth.instance.currentUser!;
//   int codCount = 0; // Variable to store COD count
//   int nonCodCount = 0; // Variable to store non-COD count
//   String currentUID = "";

//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final CollectionReference _userReference =
//       FirebaseFirestore.instance.collection('userName_email_sign_in');

//   void inputData() {
//     final User? user = auth.currentUser;
//     final uid = user?.uid;
//     currentUID = uid!;
//     log("Current UID: " + currentUID);
//     // here you write the codes to input the data into firestore
//   }

//   @override
//   void initState() {
//     super.initState();
//     inputData();
//     fetchCODData();
//     fetchNonCODData();
//   }

//   void fetchCODData() {
//     FirebaseFirestore.instance
//         .collection("received")
//         .where("UID", isEqualTo: currentUID)
//         .where("Mode of Payment", isEqualTo: "Cash on Delivery")
//         .get()
//         .then((snapshot) {
//       Future.delayed(Duration(milliseconds: 500), () {
//         setState(() {
//           codCount = snapshot.docs.length;
//         });
//       });
//     }).catchError((error) {
//       print('Error getting COD count: $error');
//     });
//   }

//   void fetchNonCODData() {
//     FirebaseFirestore.instance
//         .collection("received")
//         .where("UID", isEqualTo: currentUID)
//         .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
//         .get()
//         .then((snapshot) {
//       Future.delayed(Duration(milliseconds: 500), () {
//         setState(() {
//           nonCodCount = snapshot.docs.length;
//         });
//       });
//     }).catchError((error) {
//       print('Error getting Non-COD count: $error');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Color(0xFF191970),
//       width: MediaQuery.of(context).size.width * 0.7,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 20.0,
//           ),
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: Colors.white,
//             child: ClipOval(
//               child: user.photoURL != null
//                   ? Image.network(
//                       "${user.photoURL}",
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                     )
//                   : StreamBuilder<DocumentSnapshot>(
//                       stream: _userReference.doc(currentUID.trim()).snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasError) {
//                           return const Center(
//                             child: Text("Something Went Wrong"),
//                           );
//                         }
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (!snapshot.hasData ||
//                             snapshot.data == null ||
//                             !snapshot.data!.exists) {
//                           return const Center(
//                             child: Text("Document not found"),
//                           );
//                         }
//                         log("Nasa loob na ako");
//                         var data = snapshot.data!.data();
//                         if (data != null && data is Map<String, dynamic>) {
//                           String name = data['Name'] ??
//                               'Name not available'; // Provide a fallback value

//                           return Text(
//                             name[0],
//                             style: GoogleFonts.ubuntu(
//                               fontSize: 40,
//                               color: Color(0xFF191970),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           );
//                         } else {
//                           return const Center(
//                             child: Text("Invalid data format"),
//                           );
//                         }
//                       },
//                     ),
//             ),
//           ),
//           SizedBox(
//             height: 20.0,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: user.displayName != null
//                 ? Text(
//                     "${user.displayName}",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 : StreamBuilder<DocumentSnapshot>(
//                     stream: _userReference.doc(currentUID.trim()).snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return const Center(
//                           child: Text("Something Went Wrong"),
//                         );
//                       }
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                       if (!snapshot.hasData ||
//                           snapshot.data == null ||
//                           !snapshot.data!.exists) {
//                         return const Center(
//                           child: Text("Document not found"),
//                         );
//                       }
//                       log("Nasa loob na ako");
//                       var data = snapshot.data!.data();
//                       if (data != null && data is Map<String, dynamic>) {
//                         String name = data['Name'] ??
//                             'Name not available'; // Provide a fallback value

//                         return Text(
//                           name,
//                           style: GoogleFonts.ubuntu(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       } else {
//                         return const Center(
//                           child: Text("Invalid data format"),
//                         );
//                       }
//                     },
//                   ),
//           ),
//           SizedBox(
//             height: 14.0,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/dollar.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("received")
//                         .where("UID", isEqualTo: currentUID)
//                         .where("Mode of Payment", isEqualTo: "Cash on Delivery")
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasError) {
//                         print('Error getting COD count: ${snapshot.error}');
//                         return Text('Error getting COD count');
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator(); // Placeholder widget while loading
//                       }

//                       // Process the data
//                       codCount = snapshot.data?.docs.length ?? 0;

//                       // Update your UI accordingly
//                       return Text(
//                         '${codCount}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                           color: Colors.white,
//                         ),
//                       );
//                     },
//                   ),
//                   Text(
//                     "COD",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/contactless.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("received")
//                         .where("UID", isEqualTo: currentUID)
//                         .where("Mode of Payment",
//                             isEqualTo: "Non-Cash on Delivery")
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasError) {
//                         print('Error getting Non-COD count: ${snapshot.error}');
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator(); // Placeholder widget while loading
//                       }

//                       // Process the data
//                       nonCodCount = snapshot.data?.docs.length ?? 0;

//                       // Update your UI accordingly
//                       return Text(
//                         '${nonCodCount}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                           color: Colors.white,
//                         ),
//                       );
//                     },
//                   ),
//                   Text(
//                     "Non-COD",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/parcel.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   Text(
//                     '${codCount + nonCodCount}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "Total",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Spacer(),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'lib/images/flutter_icon.png',
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.01,
//               ),
//               Image.asset(
//                 'lib/images/firebase_icon.png',
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
//             child: Text(
//               "Powered by Flutter and Firebase\nDeveloped by The Par-Receiver Team",
//               textAlign: TextAlign.center,
//               style: GoogleFonts.ubuntu(
//                 fontSize: 12.0,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class Navbar extends StatefulWidget {
  Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final user = FirebaseAuth.instance.currentUser!;
  int codCount = 0; // Variable to store COD count
  int nonCodCount = 0; // Variable to store non-COD count
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection('userName_email_sign_in');

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    log("Current UID: " + currentUID);
    // here you write the code to input the data into firestore
  }

  @override
  void initState() {
    super.initState();
    inputData();
    fetchCODData();
    fetchNonCODData();
  }

  void fetchCODData() {
    FirebaseFirestore.instance
        .collection("received")
        .where("UID", isEqualTo: currentUID)
        .where("ModeofPayment", isEqualTo: "Cash on Delivery")
        .get()
        .then((snapshot) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          codCount = snapshot.docs.length;
        });
      });
    }).catchError((error) {
      print('Error getting COD count: $error');
    });
  }

  Future<int> getCODOrders() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("parcels")
          .where("UID", isEqualTo: currentUID)
          .where("ModeofPayment", isEqualTo: "Cash on Delivery")
          .get();
      setState(() {
        codCount = snapshot.docs.length;
        print('COD count of the current user: $codCount');
      });
      return codCount;
    } catch (error) {
      print('Error getting COD count: $error');
      return 0; // or handle the error as needed
    }
  }

  void fetchNonCODData() {
    FirebaseFirestore.instance
        .collection("received")
        .where("UID", isEqualTo: currentUID)
        .where("ModeofPayment", isEqualTo: "Non-Cash on Delivery")
        .get()
        .then((snapshot) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          nonCodCount = snapshot.docs.length;
        });
      });
    }).catchError((error) {
      print('Error getting Non-COD count: $error');
    });
  }

  void deleteNonCODData() {
    FirebaseFirestore.instance
        .collection("parcels")
        .where("UID", isEqualTo: currentUID)
        .where("ModeofPayment", isEqualTo: "Non-Cash on Delivery")
        .get()
        .then((snapshot) {
      // Iterate through each document and delete it
      for (var doc in snapshot.docs) {
        doc.reference.delete().then((_) {
          print('Document ${doc.id} deleted successfully');
        }).catchError((error) {
          print('Error deleting document ${doc.id}: $error');
        });
      }
    }).catchError((error) {
      print('Error fetching Non-COD documents: $error');
    });
  }

  void _deleteAccount(int codCount) async {
    try {
      // Check if the user is authenticated
      log("Trying to delete User account...");
      if (user.email != null && codCount == 0) {
        log("User account deleted successfully...");
        // Delete user data from Firestore
        await _userReference.doc(currentUID.trim()).delete();
        // Delete the user from Firebase Authentication
        await user.delete();
        // Logout the user
        deleteNonCODData();
        await FirebaseAuth.instance.signOut();
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Account deleted successfully.',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ));
        // Navigate to the login page
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginOrRegister()));
      } else if (codCount != 0) {
        // If the user is not authenticated, show an error Snackbar
        log("User account deletion unsuccessful...");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Failed to delete account: User still has COD orders.',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      // Show failure Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to delete account: $error',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showDeleteAccountDialog() async {
    int codCount = await getCODOrders();
    log("COD Documents from the delete user function: ${codCount}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete your Account?',
            style:
                GoogleFonts.ubuntu(fontSize: 15.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.ubuntu(
                fontSize: 13.0,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                    text: 'WARNING: ',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(
                    text:
                        'If you have COD orders, kindly delete them one by one to retrieve money inside the machine.\nDeleting your account will delete all your past and present transactions.'),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteAccount(codCount); // Then call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF191970),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: user.photoURL != null
                  ? Image.network(
                      "${user.photoURL}",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : StreamBuilder<DocumentSnapshot>(
                      stream: _userReference.doc(currentUID.trim()).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Something Went Wrong"),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            !snapshot.data!.exists) {
                          return const Center(
                            child: Text("Document not found"),
                          );
                        }
                        log("Nasaloob na ako");
                        var data = snapshot.data!.data();
                        if (data != null && data is Map<String, dynamic>) {
                          String name = data['Name'] ??
                              'Name not available'; // Provide a fallback value
                          return Text(
                            name[0],
                            style: GoogleFonts.ubuntu(
                              fontSize: 40,
                              color: Color(0xFF191970),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text("Invalid data format"),
                          );
                        }
                      },
                    ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: user.displayName != null
                ? Text(
                    "${user.displayName}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : StreamBuilder<DocumentSnapshot>(
                    stream: _userReference.doc(currentUID.trim()).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Something Went Wrong"),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data!.exists) {
                        return const Center(
                          child: Text("Document not found"),
                        );
                      }
                      log("Nasaloob na ako");
                      var data = snapshot.data!.data();
                      if (data != null && data is Map<String, dynamic>) {
                        String name = data['Name'] ??
                            'Name not available'; // Provide a fallback value
                        return Text(
                          name,
                          style: GoogleFonts.ubuntu(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("Invalid data format"),
                        );
                      }
                    },
                  ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(
                    'lib/images/dollar.png',
                    height: 50.0,
                    width: 50.0,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("received")
                        .where("UID", isEqualTo: currentUID)
                        .where("ModeofPayment", isEqualTo: "Cash on Delivery")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print('Error getting COD count: ${snapshot.error}');
                        return Text('Error getting COD count');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Placeholder widget while loading
                      }
                      // Process the data
                      codCount = snapshot.data?.docs.length ??
                          0; // Update your UI accordingly
                      return Text(
                        '${codCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text(
                    "COD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    'lib/images/contactless.png',
                    height: 50.0,
                    width: 50.0,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("received")
                        .where("UID", isEqualTo: currentUID)
                        .where("ModeofPayment",
                            isEqualTo: "Non-Cash on Delivery")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print('Error getting Non-COD count: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Placeholder widget while loading
                      }
                      // Process the data
                      nonCodCount = snapshot.data?.docs.length ??
                          0; // Update your UI accordingly
                      return Text(
                        '${nonCodCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  Text(
                    "Non-COD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    'lib/images/parcel.png',
                    height: 50.0,
                    width: 50.0,
                  ),
                  Text(
                    '${codCount + nonCodCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text(
              "Machine Status",
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MachineStatus()));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.white),
            title: Text(
              "Delete Account",
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
          Spacer(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/images/flutter_icon.png',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Image.asset(
                'lib/images/firebase_icon.png',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.1,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Text(
              "Powered by Flutter and Firebase\nDeveloped by The Par-Receiver Team",
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontSize: 12.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// class Navbar extends StatefulWidget {
//   Navbar({Key? key}) : super(key: key);

//   @override
//   State<Navbar> createState() => _NavbarState();
// }

// class _NavbarState extends State<Navbar> {
//   final user = FirebaseAuth.instance.currentUser!;
//   int codCount = 0; // Variable to store COD count
//   int nonCodCount = 0; // Variable to store non-COD count
//   String currentUID = "";

//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final CollectionReference _userReference =
//       FirebaseFirestore.instance.collection('userName_email_sign_in');

//   void inputData() {
//     final User? user = auth.currentUser;
//     final uid = user?.uid;
//     currentUID = uid!;
//     log("Current UID: " + currentUID);
//     // here you write the codes to input the data into firestore
//   }

//   @override
//   void initState() {
//     super.initState();
//     inputData();
//     fetchCODData();
//     fetchNonCODData();
//   }

//   void fetchCODData() {
//     FirebaseFirestore.instance
//         .collection("received")
//         .where("UID", isEqualTo: currentUID)
//         .where("Mode of Payment", isEqualTo: "Cash on Delivery")
//         .get()
//         .then((snapshot) {
//       Future.delayed(Duration(milliseconds: 500), () {
//         setState(() {
//           codCount = snapshot.docs.length;
//         });
//       });
//     }).catchError((error) {
//       print('Error getting COD count: $error');
//     });
//   }

//   void fetchNonCODData() {
//     FirebaseFirestore.instance
//         .collection("received")
//         .where("UID", isEqualTo: currentUID)
//         .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
//         .get()
//         .then((snapshot) {
//       Future.delayed(Duration(milliseconds: 500), () {
//         setState(() {
//           nonCodCount = snapshot.docs.length;
//         });
//       });
//     }).catchError((error) {
//       print('Error getting Non-COD count: $error');
//     });
//   }

//   void _showDeleteAccountDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete your Account?'),
//           content: RichText(
//             text: TextSpan(
//               style: GoogleFonts.ubuntu(
//                 fontSize: 12.0,
//                 color: Colors.black,
//               ),
//               children: [
//                 TextSpan(
//                   text: 'WARNING: ',
//                   style: GoogleFonts.ubuntu(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextSpan(
//                   text:
//                       'If you have COD orders, kindly delete them one by one to retrieve money inside the machine.\nDeleting your account will delete all your past and present transactions.',
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text(
//                 'Delete',
//                 style: TextStyle(color: Colors.red),
//               ),
//               onPressed: _deleteAccount,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteAccount() async {
//     try {
//       // Delete user data from Firestore
//       await _userReference.doc(currentUID.trim()).delete();

//       // Delete the user from Firebase Authentication
//       await user.delete();

//       // Log out the user
//       await FirebaseAuth.instance.signOut();

//       // Show success Snackbar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Account deleted successfully.'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate to the login page
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => LoginOrRegister()),
//       );
//     } catch (error) {
//       // Show failure Snackbar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to delete account: $error'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Color(0xFF191970),
//       width: MediaQuery.of(context).size.width * 0.7,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 20.0,
//           ),
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: Colors.white,
//             child: ClipOval(
//               child: user.photoURL != null
//                   ? Image.network(
//                       "${user.photoURL}",
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                     )
//                   : StreamBuilder<DocumentSnapshot>(
//                       stream: _userReference.doc(currentUID.trim()).snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasError) {
//                           return const Center(
//                             child: Text("Something Went Wrong"),
//                           );
//                         }
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (!snapshot.hasData ||
//                             snapshot.data == null ||
//                             !snapshot.data!.exists) {
//                           return const Center(
//                             child: Text("Document not found"),
//                           );
//                         }
//                         log("Nasa loob na ako");
//                         var data = snapshot.data!.data();
//                         if (data != null && data is Map<String, dynamic>) {
//                           String name = data['Name'] ??
//                               'Name not available'; // Provide a fallback value

//                           return Text(
//                             name[0],
//                             style: GoogleFonts.ubuntu(
//                               fontSize: 40,
//                               color: Color(0xFF191970),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           );
//                         } else {
//                           return const Center(
//                             child: Text("Invalid data format"),
//                           );
//                         }
//                       },
//                     ),
//             ),
//           ),
//           SizedBox(
//             height: 20.0,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: user.displayName != null
//                 ? Text(
//                     "${user.displayName}",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 : StreamBuilder<DocumentSnapshot>(
//                     stream: _userReference.doc(currentUID.trim()).snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return const Center(
//                           child: Text("Something Went Wrong"),
//                         );
//                       }
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                       if (!snapshot.hasData ||
//                           snapshot.data == null ||
//                           !snapshot.data!.exists) {
//                         return const Center(
//                           child: Text("Document not found"),
//                         );
//                       }
//                       log("Nasa loob na ako");
//                       var data = snapshot.data!.data();
//                       if (data != null && data is Map<String, dynamic>) {
//                         String name = data['Name'] ??
//                             'Name not available'; // Provide a fallback value

//                         return Text(
//                           name,
//                           style: GoogleFonts.ubuntu(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       } else {
//                         return const Center(
//                           child: Text("Invalid data format"),
//                         );
//                       }
//                     },
//                   ),
//           ),
//           SizedBox(
//             height: 14.0,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/dollar.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("received")
//                         .where("UID", isEqualTo: currentUID)
//                         .where("Mode of Payment", isEqualTo: "Cash on Delivery")
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasError) {
//                         print('Error getting COD count: ${snapshot.error}');
//                         return Text('Error getting COD count');
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator(); // Placeholder widget while loading
//                       }

//                       // Process the data
//                       codCount = snapshot.data?.docs.length ?? 0;

//                       // Update your UI accordingly
//                       return Text(
//                         '${codCount}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                           color: Colors.white,
//                         ),
//                       );
//                     },
//                   ),
//                   Text(
//                     "COD",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/contactless.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("received")
//                         .where("UID", isEqualTo: currentUID)
//                         .where("Mode of Payment",
//                             isEqualTo: "Non-Cash on Delivery")
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.hasError) {
//                         print('Error getting Non-COD count: ${snapshot.error}');
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator(); // Placeholder widget while loading
//                       }

//                       // Process the data
//                       nonCodCount = snapshot.data?.docs.length ?? 0;

//                       // Update your UI accordingly
//                       return Text(
//                         '${nonCodCount}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                           color: Colors.white,
//                         ),
//                       );
//                     },
//                   ),
//                   Text(
//                     "Non-COD",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Image.asset(
//                     'lib/images/parcel.png',
//                     height: 50.0,
//                     width: 50.0,
//                   ),
//                   Text(
//                     '${codCount + nonCodCount}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "Total",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Spacer(),
//           ListTile(
//             leading: Icon(Icons.delete, color: Colors.white),
//             title: Text(
//               "Delete Account",
//               style: GoogleFonts.ubuntu(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             onTap: _showDeleteAccountDialog,
//           ),
//           SizedBox(height: 20.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'lib/images/flutter_icon.png',
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.01,
//               ),
//               Image.asset(
//                 'lib/images/firebase_icon.png',
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
//             child: Text(
//               "Powered by Flutter and Firebase\nDeveloped by The Par-Receiver Team",
//               textAlign: TextAlign.center,
//               style: GoogleFonts.ubuntu(
//                 fontSize: 12.0,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }