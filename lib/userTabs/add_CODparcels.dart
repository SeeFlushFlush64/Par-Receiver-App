import 'dart:developer';
import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:modernlogintute/services/openCashContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/trial/add_item.dart';
import 'package:modernlogintute/userTabs/added_details.dart';
import 'package:modernlogintute/userTabs/requiredfields.dart';
import 'package:quickalert/quickalert.dart';

class AddCODParcels extends StatefulWidget {
  const AddCODParcels({super.key});

  @override
  State<AddCODParcels> createState() => _AddCODParcelsState();
}

class _AddCODParcelsState extends State<AddCODParcels> {
  int _codOrders = 0;
  Set<String> pickedContainers = {};

  void setcodCount() {
    _codOrders++;
  }

  final _formKey = GlobalKey<FormState>();

  String fontfamily = "OpenSans";
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  // TextEditingController modePaymentController = TextEditingController();
  TextEditingController trackingIDController = TextEditingController();
  TextEditingController cashContainerController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController timeAddedController = TextEditingController();
  // TextEditingController addOrReceivedController = TextEditingController();
  String selectedPaymentMode = 'Cash on Delivery';
  String selectedCashContainer = 'Select Cash Container';

  int errorMessageDuration = 3; // seconds

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
  String? selectedPaymentModeError;
  String? selectedCashContainerError;

  // Add this set to track occupied containers
  Set<String> occupiedContainers = {};

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
        selectedCashContainerError = null;
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
      borderSide: BorderSide(
        color: Colors.red, // Set the border color to red for errors
        width: 2.0,
      ),
    );
  }

  String? validateProductName(String value) {
    if (value.isEmpty) {
      return 'Product name is required!';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
      return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
    }
    return null;
  }

  String? validateTrackingID(String value) {
    if (value.isEmpty) {
      return 'Tracking ID is required!';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
      return 'Invalid tracking ID. Only uppercase alphanumeric characters are allowed.';
    }
    return null;
  }

  String? validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Price is required!';
  }

  // Regular expression to check if the input is a valid price with up to two decimal places
  RegExp regExp = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!regExp.hasMatch(value)) {
    return 'Invalid price. Please enter a valid number with up to two decimal places.';
  }

  // Split the value on the decimal point
  List<String> parts = value.split('.');
  String integerPart = parts[0];

  // Check if the integer part has more than 5 digits
  if (integerPart.length > 5) {
    return 'Invalid price. The price cannot exceed 5 digits.';
  }

  // Automatically format the value to two decimal places if no decimal point is present
  if (value.indexOf('.') == -1) {
    priceController.text = double.parse(value).toStringAsFixed(2);
  }

  return null;
}


  Future<void> showAlertDialog(BuildContext context) async {
    QuickAlert.show(
      context: context,
      title: "Quick Note!",
      text:
          "Make sure you are close to the machine when placing COD parcels on Par-Receiver",
      type: QuickAlertType.info,
      confirmBtnColor: Color(0xFF191970),
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String charContainer) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Parcel Information",
            textAlign: TextAlign.center,
            style:
                GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "•  Are the given information correct?\n• Incorrect Tracking Number will make the parcel invalid for the machine.",
            textAlign: TextAlign.justify,
            style: GoogleFonts.ubuntu(
                fontSize: 14.0, fontWeight: FontWeight.normal),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User cancelled
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User confirmed
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Proceed with adding the parcel
      String standard_month = '${time.month}';
      String date =
          '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
      String timeAdded =
          '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      setcodCount();

      if (_formKey.currentState!.validate() && _codOrders <= 4) {
        setState(() {
          isLoading = true;
        });
        inputData();
        OpenCashContainer openCashContainer = OpenCashContainer(
          cashContainer: charContainer,
          status: "open",
        );
        AddedDetails addedDetails = AddedDetails(
          // cashContainer: cashContainerController,
          addOrReceived: "+",
          modeOfPayment: selectedPaymentMode,
          productName: productNameController.text,
          trackingId: trackingIDController.text,
          price: double.parse(priceController.text),
          dateAdded: date,
          timeAdded: timeAdded,
          uid: currentUID,
          unread: true,
        );

        Parcels parcel = Parcels(
          productName: productNameController.text,
          modeOfPayment: selectedPaymentMode,
          trackingId: trackingIDController.text,
          price: double.parse(priceController.text),
          cashContainer: cashContainerController.text,
          delivered: false,
          dateAdded: date,
          timeAdded: timeAdded,
          uid: currentUID,
        );

        // Call addParcelAndNavigateToHome() here before navigating to AddItem
        await addParcelAndNavigateToHome(
            parcel, addedDetails, openCashContainer, standard_month, context);
        log("Ito yung pangalan ng parcel: " + productNameController.text);
        log("Ito yung tracking number ng parcel: " + trackingIDController.text);
      } else if (_formKey.currentState!.validate() && _codOrders >= 5) {
        // Show insufficient cash containers dialog
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text('No Cash Containers Available'),
            content: Text('Insufficient cash containers. Pay through Non-COD?'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: Text('No'),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('Yes'),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      }
    }
  }

  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Reset fields?",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Discard information on the add parcel form?",
            textAlign: TextAlign.justify,
            style: GoogleFonts.ubuntu(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User cancelled
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User confirmed
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Reset the form fields
      setState(() {
        productNameController.text = "";
        priceController.text = "";
        selectedCashContainer = 'Select Cash Container';
        trackingIDController.text = "";
        cashContainerController.text = "";
      });
    }
  }

  Stream<List<String>> getCashContainerStream() {
    return FirebaseFirestore.instance
        .collection('parcels')
        .snapshots()
        .map((snapshot) {
      List<String> cashContainers = [];
      occupiedContainers.clear();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        cashContainers.add(data['cashContainer']);
        // occupiedContainers.add(data['cashContainer']);
      }

      occupiedContainers.clear();
      occupiedContainers.addAll(cashContainers);
      pickedContainers
          .removeWhere((container) => !cashContainers.contains(container));

      return cashContainers;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['showAlertDialog'] == true) {
        showAlertDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text("ADD COD PARCELS"),
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

                    // const SizedBox(
                    //   height: 10.0,
                    // ),

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
                                padding: EdgeInsets.only(left: 6.0),
                                child: Image.asset(
                                  'lib/images/ultrasonic sensor.png',
                                  height: 80.0,
                                  width: 70.0,
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
                                "Ensure that the front barcode scanner is not triggered by ultrasonic sensor before pressing the Add Parcel button",
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
                    // const SizedBox(
                    //   height: 10.0,
                    // ),
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
                                  'lib/images/peso_removed_bg.png',
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
                                "Ensure correct and exact parcel price. If the price includes decimal, kindly include it too",
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

                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: productNameController,
                      validator: ((value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required!';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
                          return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
                        }
                        return null;
                      }),
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
                    TextFormField(
                      controller: trackingIDController,
                      validator: (value) {
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
                        hintText: "Tracking Number",
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
                    Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.grey.shade600,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          ),
                          validator: validatePrice,
                          decoration: InputDecoration(
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
                            hintText: 'Price',
                            border: textFieldBorder(),
                            prefixIcon: Icon(Icons.attach_money,
                                color: Color(0xFF191970)),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        StreamBuilder<List<String>>(
                          stream: getCashContainerStream(),
                          builder: (context, snapshot) {
                            return DropdownButtonFormField<String>(
                              value: selectedCashContainer,
                              validator: (value) {
                                if (value == 'Select Cash Container') {
                                  selectedCashContainerError =
                                      'Please choose a cash container';
                                  clearErrorMessage();
                                  return selectedCashContainerError;
                                }
                                if (occupiedContainers.contains(value)) {
                                  selectedCashContainerError =
                                      'Cash Container $value is already occupied';
                                  clearErrorMessage();
                                  return selectedCashContainerError;
                                }

                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedCashContainer = value!;
                                  cashContainerController.text =
                                      selectedCashContainer;
                                  clearErrorMessage();
                                });
                              },
                              items: [
                                'Select Cash Container',
                                'Cash Container A',
                                'Cash Container B',
                                'Cash Container C',
                                'Cash Container D'
                              ]
                                  .map((container) => DropdownMenuItem(
                                        value: container,
                                        child: Text(
                                          container,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
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
                                hintText: 'Cash Container',
                                border: textFieldBorder(),
                                prefixIcon: Icon(Icons.account_balance_wallet,
                                    color: Color(0xFF191970)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            String charContainer = cashContainerController
                                .text[cashContainerController.text.length - 1];
                            log(charContainer);
                            // Display the confirmation alert using QuickAlert
                            await _showConfirmationDialog(
                                context, charContainer);
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
                          onPressed: () async {
                            await _showResetConfirmationDialog(context);
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
      Parcels parcel,
      AddedDetails addedDetails,
      OpenCashContainer openCashContainer,
      String standard_month,
      BuildContext context) async {
    bool codDetailsComplete = false;
    final openCashContainerRef =
        FirebaseFirestore.instance.collection('open').doc("CashContainer");
    final parcelRef = FirebaseFirestore.instance
        .collection('parcels')
        .doc(trackingIDController.text);
    final existingParcel = await parcelRef.get();
    final addedDetailsRef = FirebaseFirestore.instance
        .collection('added')
        .doc(trackingIDController.text);
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
      if (occupiedContainers.contains(parcel.cashContainer)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cash Container ${parcel.cashContainer} is already occupied.',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if the chosen cash container is already assigned to another parcel
      final parcelWithSameCashContainer = await FirebaseFirestore.instance
          .collection('parcels')
          .where('Cash Container', isEqualTo: parcel.cashContainer)
          .get();

      if (parcelWithSameCashContainer.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${parcel.cashContainer} is already assigned to another parcel.',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Proceed with adding the parcel
      parcel.id = parcelRef.id;
      openCashContainer.id = openCashContainerRef.id;
      addedDetails.id = addedDetailsRef.id;
      final data = parcel.toJson();
      final add = addedDetails.toJson();
      final open = openCashContainer.toJson();
      await openCashContainerRef.set(open).whenComplete(() => null);
      await addedDetailsRef.set(add).whenComplete(() => null);
      await parcelRef.set(data).whenComplete(
        () {
          codDetailsComplete = true;
          log('Parcel inserted');
        },
      );
      if (codDetailsComplete == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItem(
              trackingNumber: trackingIDController.text,
              monthName:
                  '${monthNames.elementAt(int.parse(standard_month) - 1)}',
              productName: productNameController.text,
              day: '${time.day}',
              time: '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              cashContainer: cashContainerController.text,
            ),
          ),
        );
      }
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
  }
}


