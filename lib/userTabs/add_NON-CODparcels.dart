import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/requiredfields.dart';

class AddNONCODParcels extends StatefulWidget {
  const AddNONCODParcels({super.key});

  @override
  State<AddNONCODParcels> createState() => _AddNONCODParcelsState();
}

class _AddNONCODParcelsState extends State<AddNONCODParcels> {
  Set<String> pickedContainers = {};

  final _formKey = GlobalKey<FormState>();

  String fontfamily = "OpenSans";
  TextEditingController productNameController = TextEditingController();
  TextEditingController trackingIDController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController timeAddedController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String selectedPaymentMode = 'Non-Cash on Delivery';

  int errorMessageDuration = 3; // seconds
  String? selectedPaymentModeError;
  String currentUID = "";
  bool isLoading = false;

  var time = DateTime.now();

  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    // print(currentUID);
    // here you write the codes to input the data into firestore
  }

  void clearErrorMessage() {
    Future.delayed(Duration(seconds: errorMessageDuration), () {
      setState(() {
        selectedPaymentModeError = null;
      });
    });
  }

  OutlineInputBorder textFieldBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Color(0xFF191970), // Set the border color to dark blue
        width: 2.0,
      ),
    );
  }

  OutlineInputBorder errorTextFieldBorder() {
    return OutlineInputBorder(
      // borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.red, // Set the border color to red for errors
        width: 2.0,
      ),
    );
  }

  String? validateProductName(String value) {
    // Allow alphanumeric, spaces, and dashes
    if (value.isEmpty) {
      return 'Product name is required!';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
      return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
    }
    return null;
  }

  String? validateTrackingID(String value) {
    // Allow only uppercase alphanumeric, no special characters or spaces
    if (value.isEmpty) {
      return 'Tracking ID is required!';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
      return 'Invalid tracking ID. Only uppercase alphanumeric characters are allowed.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text("ADD NON-COD PARCELS"),
          elevation: 0,
          backgroundColor: Colors.grey.shade50,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ubuntu(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF191970),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12.0,
                    ),
                    Container(
                      height: 16.0,
                      color: Colors.grey.shade200,
                    ),
                    Container(
                      color: Colors.grey.shade200,
                      child: SizedBox(
                        // color: Colors.grey.shade200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Image.asset(
                                  'lib/images/firestore_logo.png',
                                  height: 45.0,
                                  width: 40.0,
                                  // color: Color(0xFF191970),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   flex: 1,
                            //   child: Container(),
                            // ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Flexible(
                              flex: 10,
                              child: Text(
                                "Ensure correct Tracking Number. Copy Tracking Number from online shopping platform to prevent typographical errors.",
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 16.0,
                      color: Colors.grey.shade200,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    TextFormField(
                      controller: productNameController,
                      // validator: validateProductName(productNameController.text),
                      validator: ((value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required!';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
                          return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
                        }
                        return null;
                      }),
                      // validator: (controller) =>
                      //     controller == null ? null : "Product name is required!",
                      cursorColor: Colors.grey.shade600,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.shopping_bag, color: Color(0xFF191970)),
                        hintText: "Product Name",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: fontfamily,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color(0xFF191970),
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: textFieldBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),

                    //DITO MO IADD YUNG TINANGGAL MO FOR CHATGPT

                    TextFormField(
                      controller: trackingIDController,
                      // validator: validateTrackingID(trackingIDController.text),
                      // validator: (controller) => (controller is String)
                      //     ? null
                      //     : "Tracking ID should be a String",
                      validator: (value) {
                        // Allow only uppercase alphanumeric, no special characters or spaces
                        if (value == null || value.isEmpty) {
                          return 'Tracking ID is required!';
                        }
                        if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                          return 'Invalid tracking ID. Only uppercase alphanumeric characters are allowed.';
                        }
                        return null;
                      },
                      cursorColor: Colors.grey.shade600,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.confirmation_number,
                            color: Color(0xFF191970)),
                        hintText: "Tracking ID",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: fontfamily,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color(0xFF191970),
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: textFieldBorder(),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            String standard_month = '${time.month}';
                            String date =
                                '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
                            String timeAdded =
                                '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading =
                                    true; // Set loading to true when starting processing
                              });
                              inputData();
                              Parcels parcel = Parcels(
                                // docUID: trackingIDController.text,
                                price: double.parse('0'),
                                productName: productNameController.text,
                                modeOfPayment: selectedPaymentMode,
                                trackingId: trackingIDController.text,
                                delivered: false,
                                dateAdded: date,
                                timeAdded: timeAdded,
                                uid: currentUID,
                              );

                              await addParcelAndNavigateToHome(parcel, context);

                              setState(() {});
                            } else if (_formKey.currentState!.validate()) {}
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF191970),
                          ),
                          child: Text(
                            'Add Parcel',
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => {
                            setState(() {
                              productNameController.text = "";
                              selectedPaymentMode = 'Select Mode of Payment';
                              trackingIDController.text = "";
                            })
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF191970),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future addParcelAndNavigateToHome(
      Parcels parcel, BuildContext context) async {
    final parcelRef = FirebaseFirestore.instance
        .collection('parcels')
        .doc(trackingIDController.text);
    final existingParcel = await parcelRef.get();
    if (existingParcel.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Parcel with tracking ID ${trackingIDController.text} already exists.',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      parcel.id = parcelRef.id;
      final data = parcel.toJson();
      await parcelRef.set(data).whenComplete(
        () {
          log('Parcel inserted');
          // CircularProgressIndicator(
          //   color: Color(0xFF191970),
          // );
          // Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ParcelTabs(),
            ),
          );
        },
      );
      // Set a boolean variable to track whether the parcel was added
      bool parcelAdded = true;

      // Show the "Parcel Added" message only if the parcel was added successfully
      if (parcelAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Parcel added',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      productNameController.text = "";
      trackingIDController.text = "";
    }

    // Navigator.pop(context);
  }
}
