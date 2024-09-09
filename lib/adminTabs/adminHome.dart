import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modernlogintute/adminTabs/appUsers.dart';
import 'package:modernlogintute/components/barcodeScanner.dart';
import 'package:modernlogintute/components/occupiedOrNot.dart';
import 'package:modernlogintute/adminTabs/adminRegister.dart';
import 'package:modernlogintute/pages/cabinetwidget.dart';
import 'package:modernlogintute/pages/login_or_register.dart';
import 'package:modernlogintute/pages/register_page.dart';
import 'package:modernlogintute/services/auth_services.dart';
import 'package:modernlogintute/userTabs/userName_email_sign_in.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class AdminHome extends StatefulWidget {
  // final PersistentTabController controller; // Add this line

  AdminHome({
    super.key,
  });

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final user = FirebaseAuth.instance.currentUser!;
  int codCount = 0; // Variable to store COD count
  int nonCodCount = 0; // Variable to store non-COD count
  double totalPrice = 0.0;
  bool showTotalPrice = true; // Variable to toggle visibility
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool showAllUsers = false;
  int codPrivilege = 0;
  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection('userName_email_sign_in');

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
  }

  @override
  void initState() {
    super.initState();

    inputData();
    fetchCODData();
    fetchNonCODData();
  }

  void googleAddUser() async {
    UserNameEmailSignIn userNameEmailSignIn = UserNameEmailSignIn(
      name: user.displayName!,
      uid: user.uid,
      codLimits: 4,
    );
    final userNameEmailSignInRef = FirebaseFirestore.instance
        .collection('userName_email_sign_in')
        .doc(currentUID);
    userNameEmailSignIn.id = userNameEmailSignInRef.id;
    final userName = userNameEmailSignIn.toJson();
    await userNameEmailSignInRef.set(userName).whenComplete(() => null);
  }

  void fetchCODData() {
    FirebaseFirestore.instance
        .collection("parcels")
        .where("Mode of Payment", isEqualTo: "Cash on Delivery")
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

  void fetchNonCODData() {
    FirebaseFirestore.instance
        .collection("parcels")
        .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
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

  void _deleteAccount(int codCount) async {
    try {
      // Check if the user is authenticated
      log(
        "Trying to delete User account...",
      );
      if (user.email != null && codCount == 0) {
        log(
          "User account deleted successfully...",
        );
        // Delete user data from Firestore
        await _userReference
            .doc("s2h65s2vjcR8rQkkRjMjPXTXtjo1".trim())
            .delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        // Log out the user
        // deleteNonCODData();
        await FirebaseAuth.instance.signOut();

        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account deleted successfully.',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the login page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginOrRegister()),
        );
      } else if (codCount != 0) {
        // If the user is not authenticated, show an error Snackbar
        log(
          "User account deletion unsuccessful...",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete account: User still has COD orders.',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // Show failure Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete account: $error',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> getCODOrders() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("parcels")
          .where("UID", isEqualTo: "s2h65s2vjcR8rQkkRjMjPXTXtjo1")
          .where("Mode of Payment", isEqualTo: "Cash on Delivery")
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

  void _showDeleteAccountDialog() async {
    int codCount = await getCODOrders();
    log(
      "COD Documents from the delete user function: ${codCount}",
    );
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
                  ),
                ),
                TextSpan(
                  text:
                      'If you have COD orders, kindly delete them one by one to retrieve money inside the machine.\nDeleting your account will delete all your past and present transactions.',
                ),
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
    googleAddUser();
    return SafeArea(
      child: Scaffold(
        drawer: AdminNavbar(),
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Container(
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 30.0,
                    color: Color(0xFF191970),
                    onPressed: signUserOut,
                    icon: Icon(Icons.logout_outlined),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(right: 15.0),
            //   child: Container(
            //     child: Align(
            //       alignment: Alignment.center,
            //       child: GestureDetector(
            //         onTap: () {
            //           // Handle the onTap event (e.g., trigger Google Sign In)
            //           // You can add your Google Sign In logic here
            //           // Example: signInWithGoogle();
            //           CircularProgressIndicator();
            //           AuthService().signInWithGoogle();
            //         },
            //         child: CircleAvatar(
            //           radius: 15.0,
            //           backgroundImage: NetworkImage(
            //             // Replace with the URL of your profile picture
            //             '${user.photoURL}',
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
          // title: Text("Par-Receiver"),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade50,
          titleTextStyle: GoogleFonts.ubuntu(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF191970),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 25.0,
                    ),
                    Text(
                      "Welcome back!",
                      // "Welcome, ${user.displayName!.split(' ')[0]}",
                      style: GoogleFonts.ubuntu(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .15,
                  width: MediaQuery.sizeOf(context).width * .90,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF191970),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Par-Receiver\nOverall Cash Balance',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          showTotalPrice
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showTotalPrice = !showTotalPrice;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ListTile(
                                    subtitle: StreamBuilder<double>(
                                      stream:
                                          calculateTotalPriceStream(currentUID),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (!snapshot.hasData) {
                                          return Text(
                                            showTotalPrice
                                                ? "₱ 0.00"
                                                : "₱ *****",
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.03,
                                              color: Colors.white,
                                            ),
                                          );
                                        } else {
                                          double totalPrice =
                                              snapshot.data ?? 0.0;
                                          String totalPriceString =
                                              showTotalPrice
                                                  ? totalPrice
                                                      .toStringAsFixed(2)
                                                  : '*****';

                                          return Text(
                                            '₱ $totalPriceString',
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.03,
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Lottie.asset(
                            'lib/images/shopping_cart.json',
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * .08,
                      width: MediaQuery.sizeOf(context).width * .45,
                      child: Card(
                        child: ListTile(
                          leading: codCount == 0
                              ? Text(
                                  "0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    color: Color(0xFF191970),
                                  ),
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("parcels")
                                      .where("Mode of Payment",
                                          isEqualTo: "Cash on Delivery")
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      print(
                                          'Error getting COD count: ${snapshot.error}');
                                      return Text('Error getting COD count');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Placeholder widget while loading
                                    }

                                    // Process the data
                                    final codCount =
                                        snapshot.data?.docs.length ?? 0;

                                    // Update your UI accordingly
                                    return Text(
                                      '${codCount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Color(0xFF191970),
                                      ),
                                    );
                                  },
                                ),
                          title: Text(
                            "All Pending COD",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191970),
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).height * .08,
                      width: MediaQuery.sizeOf(context).width * .45,
                      child: Card(
                        child: ListTile(
                          leading: nonCodCount == 0
                              // ? CircularProgressIndicator()
                              ? Text(
                                  "0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                    color: Color(0xFF191970),
                                  ),
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("parcels")
                                      .where("Mode of Payment",
                                          isEqualTo: "Non-Cash on Delivery")
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      print(
                                          'Error getting Non-COD count: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Placeholder widget while loading
                                    }

                                    // Process the data
                                    final nonCodCount =
                                        snapshot.data?.docs.length ?? 0;

                                    // Update your UI accordingly
                                    return Text(
                                      '${nonCodCount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Color(0xFF191970),
                                      ),
                                    );
                                  },
                                ),
                          title: Text(
                            "All Pending Non-COD",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191970),
                              fontSize: 13.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                // InkWell(
                //   onTap: () {
                //     // if (widget.controller != null) {
                //     //   widget.controller.jumpToTab(1); // Navigate to the "Users" tab
                //     // }
                //     // PersistentNavBarNavigator.pushNewScreen(
                //     //   context,
                //     //   screen: AppUsers(),
                //     //   withNavBar:
                //     //       true, // This ensures the nav bar is shown on the new screen.

                //     // );
                //   },
                //   child: Container(
                //     width: MediaQuery.sizeOf(context).width * .90,
                //     child: StreamBuilder<QuerySnapshot>(
                //       stream: FirebaseFirestore.instance
                //           .collection('userName_email_sign_in')
                //           .snapshots(),
                //       builder: (context, snapshot) {
                //         if (snapshot.connectionState ==
                //             ConnectionState.waiting) {
                //           return Center(child: CircularProgressIndicator());
                //         }

                //         if (snapshot.hasError) {
                //           return Center(
                //               child: Text('Error: ${snapshot.error}'));
                //         }

                //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                //           return Center(
                //             child: Card(
                //               child: ListTile(
                //                 contentPadding:
                //                     EdgeInsets.symmetric(horizontal: 16.0),
                //                 title: Text(
                //                   'Number of users: 0',
                //                   style: GoogleFonts.ubuntu(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 12.0,
                //                     color: Color(0xFF191970),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           );
                //         }

                //         int documentCount = snapshot.data!.docs.length - 1;
                //         if (documentCount < 0)
                //           documentCount =
                //               0; // Ensure the count doesn't go below 0

                //         return Center(
                //           child: Card(
                //             child: ListTile(
                //               leading: Icon(Icons.person),
                //               contentPadding:
                //                   EdgeInsets.symmetric(horizontal: 16.0),
                //               title: Text(
                //                 'Number of users: ${documentCount}',
                //                 style: GoogleFonts.ubuntu(
                //                   fontWeight: FontWeight.bold,
                //                   fontSize: 12.0,
                //                   color: Color(0xFF191970),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Users',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.025,
                          color: Color(0xFF191970),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  "Users and Privileges",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  "Here shows the lists of users, with their Sign in Methods (Email, Google, etc.).\nIt also shows how many cash container a certain user can use, to determine if they are limited to COD or Non-COD only.",
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height *
                                  0.002), // Adjust the padding as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.black,
                                width: 2.0), // Black border
                          ),
                          child: Icon(
                            Icons.question_mark_outlined,
                            size: MediaQuery.of(context).size.height * 0.025,
                            color: Colors.black, // Black icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * .5,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('userName_email_sign_in')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No users found.'));
                            }

                            final users = snapshot.data!.docs
                                .where((user) =>
                                    user.id != "52ihU8Gw6EbJbd38PYwCnwurj363")
                                .toList();

                            if (users.isEmpty) {
                              return Center(child: Text('No users found.'));
                            }

                            print(
                                "Number of users: ${users.length}"); // Debugging print statement

                            final displayedUsers =
                                showAllUsers ? users : users.take(2).toList();

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: displayedUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = displayedUsers[index];
                                    final userName = user['Name'];
                                    final signInWith = user['Sign in With'];
                                    final codLimits = user['COD Limits'] ?? 0;

                                    // Split the userName by whitespace
                                    final nameParts = userName.split(' ');

                                    // Determine the display name based on the number of parts
                                    String displayName;
                                    if (nameParts.length >= 4) {
                                      displayName =
                                          '${nameParts[0]} ${nameParts[1]}';
                                    } else {
                                      displayName = nameParts[0];
                                    }

                                    // Determine the leading icon based on "Sign in With" field
                                    Widget leadingIcon;
                                    if (signInWith == 'Google') {
                                      leadingIcon = Image.asset(
                                        'lib/images/google.png', // Path to Google logo asset
                                        width: 24.0,
                                        height: 24.0,
                                      );
                                    } else if (signInWith == 'Email') {
                                      leadingIcon = Image.asset(
                                        'lib/images/email.png', // Path to Email logo asset
                                        width: 24.0,
                                        height: 24.0,
                                      );
                                    } else {
                                      leadingIcon = Icon(Icons.person,
                                          color: Color(
                                              0xFF191970)); // Default icon
                                    }

                                    return InkWell(
                                      onTap: () {
                                        // showUserDialog(context, userName, userUID);
                                      },
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              displayName,
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // Lottie.asset(
                                            //   'lib/images/cashVaultAesthetic.json',
                                            // ),
                                          ],
                                        ),
                                        leading: leadingIcon,
                                        // trailing: Lottie.asset(
                                        //     'lib/images/codLimit.json'),
                                      ),
                                    );
                                  },
                                ),
                                if (users.length > 2)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showAllUsers = !showAllUsers;
                                      });
                                    },
                                    child: Text(
                                        showAllUsers ? 'See Less' : 'See More'),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * .4,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('userName_email_sign_in')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No users found.'));
                            }

                            final users = snapshot.data!.docs
                                .where((user) =>
                                    user.id != "52ihU8Gw6EbJbd38PYwCnwurj363")
                                .toList();

                            if (users.isEmpty) {
                              return Center(child: Text('No users found.'));
                            }

                            print(
                                "Number of users: ${users.length}"); // Debugging print statement

                            final displayedUsers =
                                showAllUsers ? users : users.take(2).toList();

                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: displayedUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = displayedUsers[index];
                                    final userName = user['Name'];
                                    final codLimits = user['COD Limits'] ?? 0;
                                    codPrivilege = codLimits;

                                    // Split the userName by whitespace
                                    final nameParts = userName.split(' ');

                                    // Determine the display name based on the number of parts
                                    String displayName;
                                    if (nameParts.length >= 4) {
                                      displayName =
                                          '${nameParts[0]} ${nameParts[1]}';
                                    } else {
                                      displayName = nameParts[0];
                                    }

                                    // Determine the leading icon based on "Sign in With" field

                                    return InkWell(
                                      onTap: () {
                                        // showUserDialog(context, userName, userUID);
                                      },
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        title: Row(
                                          children:
                                              List.generate(codLimits, (index) {
                                            return SizedBox(
                                              width:
                                                  32.0, // Adjust the size as needed
                                              height: 32.0,
                                              child: Image.asset(
                                                  'lib/images/cash_removed_bg.png'),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (users.length > 2)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showAllUsers = !showAllUsers;
                                      });
                                    },
                                    child: Container(),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUserOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Logout",
            textAlign: TextAlign.center,
            style:
                GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to sign out?",
            textAlign: TextAlign.justify,
            style: GoogleFonts.ubuntu(
                fontSize: 14.0, fontWeight: FontWeight.normal),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close the dialog

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Account successfully logged out",
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  Stream<double> calculateTotalPriceStream(String currentUID) {
    return FirebaseFirestore.instance.collection("parcels").snapshots().map(
      (QuerySnapshot<Object?> snapshot) {
        List<double> prices = [];

        // Iterate through the documents and add the "Price" values to the list
        snapshot.docs.forEach((document) {
          var price = document['Price'] ?? 0.0; // Handle null values
          prices.add(price);
        });

        // Calculate the total value
        return prices.reduce((value, element) => value + element);
      },
    );
  }
}

Widget _buildContainer(String name, Color color, BuildContext context) {
  return Container(
    height: 30.0,
    width: 70.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          name.isNotEmpty ? Icons.person : Icons.person_outline,
          color: Colors.white,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width *
                0.0005), // Add spacing between icon and text
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis, // Handle text overflow
            maxLines: 1, // Limit to one line
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}

Widget _buildCurrentUIDContainer(
    double price, Color color, BuildContext context) {
  return Container(
    height: 30.0,
    width: 70.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person,
          color: Colors.white,
        ),
        SizedBox(width: 4.0), // Adding some space between the icon and text
        Expanded(
          child: Text(
            "₱${price.toString()}",
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
    ),
  );
}
