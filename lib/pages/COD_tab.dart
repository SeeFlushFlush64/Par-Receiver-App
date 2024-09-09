import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/services/openCashContainer.dart';
import 'package:modernlogintute/userTabs/requiredfields.dart';

import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class COD_tab extends StatefulWidget {
  COD_tab({super.key});

  @override
  State<COD_tab> createState() => _COD_tabState();
}

class _COD_tabState extends State<COD_tab> {
  final _formKey = GlobalKey<FormState>();
  String fontfamily = "Open Sans";
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController cashContainerController = TextEditingController();
  TextEditingController modePaymentController = TextEditingController();
  TextEditingController trackingIDController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  String selectedPaymentMode = 'Cash on Delivery';
  String selectedCashContainer = 'Select Cash Container';
  int codOrders = 0;
  int codOrdersNungCurrentUser = 0;
  String currentUID = "";

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    //   // print(currentUID);
    //   // here you write the codes to input the data into firestore
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

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required!';
    }

    RegExp regExp = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!regExp.hasMatch(value)) {
      return 'Invalid price. Please enter a valid number with up to two decimal places.';
    }

    if (value.indexOf('.') == -1) {
      priceController.text = double.parse(value).toStringAsFixed(2);
    }

    return null;
  }

  String? selectedPaymentModeError;
  String? selectedCashContainerError;
  int errorMessageDuration = 3; // seconds

  void clearErrorMessage() {
    Future.delayed(Duration(seconds: errorMessageDuration), () {
      setState(() {
        selectedPaymentModeError = null;
        selectedCashContainerError = null;
      });
    });
  }

  Set<String> occupiedContainers = {};
  Set<String> pickedContainers = {};

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

  Future showConfirmationDialog(
    BuildContext context,
    Parcels parcel,
    String modeOfPayment,
    double price,
    String cashContainer,
    String productName,
  ) async {
    bool userConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Update?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to update the parcel information?",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
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

    if (userConfirmed) {
      updated(parcel, modeOfPayment, price, cashContainer, productName);
      // Fluttertoast.showToast(
      //   msg: "Parcel updated",
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 1,
      // );
    }
  }

  // void updated(Parcels parcel) {
  //   String standard_month = '${time.month}';
  //   String date =
  //       '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
  //   String timeAdded = '${time.hour}:${time.minute}';
  //   Parcels updatedParcels = Parcels(
  //     dateAdded: date,
  //     timeAdded: timeAdded,
  //     modeOfPayment: modePaymentController.text,
  //     price: double.parse(priceController.text),
  //     cashContainer: cashContainerController.text,
  //     productName: productNameController.text,
  //     trackingId: parcel.trackingId,
  //     delivered: false,
  //   );
  //   log(parcel.trackingId);
  //   log(productNameController.text);
  //   final collectionReference =
  //       FirebaseFirestore.instance.collection('parcels');
  //   collectionReference
  //       .doc(updatedParcels.trackingId)
  //       .update(updatedParcels.toJson())
  //       .whenComplete(
  //     () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Parcel updated"),
  //         ),
  //       );
  //       log('Parcel updated');
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ParcelTabs(),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future showConfirmationDialog(
  //   BuildContext context,
  //   Parcels parcel,
  //   String modeOfPayment,
  //   double price,
  //   String cashContainer,
  //   String productName,
  // ) async {
  //   QuickAlert.show(
  //     context: context,
  //     title: "Confirm Update?",
  //     type: QuickAlertType.confirm,
  //     text: "Are you sure you want to update the parcel information?",
  //     onCancelBtnTap: () {
  //       Navigator.pop(context, false);
  //     },
  //     onConfirmBtnTap: () {
  //       Navigator.pop(context, true);
  //       // updated(parcel, modeOfPayment, price, cashContainer, productName);
  //     },
  //     confirmBtnText: "Yes",
  //     cancelBtnText: "No",
  //   );
  // }

  // Future<bool> showConfirmationDialog(BuildContext context) async {
  //   return await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           "Confirm Update?",
  //           textAlign: TextAlign.center,
  //           style:
  //               GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(
  //           "Are you sure you want to update the parcel information?",
  //           textAlign: TextAlign.justify,
  //           style: GoogleFonts.ubuntu(
  //               fontSize: 14.0, fontWeight: FontWeight.normal),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context, false); // User cancelled
  //             },
  //             child: Text("No"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context, true); // User confirmed
  //             },
  //             child: Text("Yes"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeleteConfirmationDialog(
      Parcels parcel, int index, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Parcel",
            textAlign: TextAlign.center,
            style:
                GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "WARNING: ",
                  style: GoogleFonts.ubuntu(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      "You should be near the Par-Receiver machine to retrieve the cash placed inside.\nAre you sure you want to delete this parcel?",
                  style: GoogleFonts.ubuntu(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Delete the parcel and navigate
                _reference.doc(parcel.trackingId).delete();
                _addedDetailsRef.doc(parcel.trackingId).delete();
                OpenCashContainer openCashContainer = OpenCashContainer(
                  cashContainer:
                      parcel.cashContainer![parcel.cashContainer!.length - 1]!,
                  status: "open",
                );
                await openCashContainerToGetMoney(openCashContainer, context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ParcelTabs(),
                //   ),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Parcel deleted successfully',
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void updated(Parcels parcel, String modeOfPayment, double price,
      String cashContainer, String productName) {
    String standard_month = '${time.month}';
    String date =
        '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
    String timeAdded = '${time.hour}:${time.minute}';
    // inputData();
    Parcels updatedParcels = Parcels(
      dateAdded: date,
      timeAdded: timeAdded,
      modeOfPayment: modeOfPayment,
      price: price,
      cashContainer: cashContainer,
      productName: productName,
      trackingId: parcel.trackingId,
      delivered: false,
      uid: currentUID,
    );
    log(parcel.trackingId);
    log(productName);
    final collectionReference =
        FirebaseFirestore.instance.collection('parcels');
    collectionReference
        .doc(updatedParcels.trackingId)
        .update(updatedParcels.toJson())
        .whenComplete(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Parcel updated",
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        log('Parcel updated');
        // Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ParcelTabs(),
          ),
        );
      },
    );
  }

  // Future showUpdateParcelDialog(BuildContext context, Parcels parcel) async {
  //   bool userConfirmed = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           "Update Parcel?",
  //           textAlign: TextAlign.center,
  //           style:
  //               GoogleFonts.ubuntu(fontSize: 18.0, fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(
  //           "•  Update this parcel's information",
  //           textAlign: TextAlign.justify,
  //           style: GoogleFonts.ubuntu(
  //               fontSize: 14.0, fontWeight: FontWeight.normal),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context, false); // User cancelled
  //             },
  //             child: Text("No"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // User confirmed
  //               Navigator.pop(context, true);
  //               updated(parcel);
  //             },
  //             child: Text("Yes"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   //

  //   return userConfirmed;
  //   // Now, you can use the value of userConfirmed to determine if the user pressed "Yes" or "No"
  // }

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('parcels');
  final CollectionReference _addedDetailsRef =
      FirebaseFirestore.instance.collection('added');
  // void codOrdersNiCurrentUser() {
  //   inputData();
  //   StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection("parcels")
  //         .where("UID", isEqualTo: currentUID) // Filter documents by UID
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return CircularProgressIndicator();
  //       }

  //       if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       }

  //       if (!snapshot.hasData || snapshot.data == null) {
  //         return Text('No data available');
  //       }

  //       var parcelCount = snapshot.data!.docs.length;
  //       codOrdersNungCurrentUser = parcelCount;
  //       print(codOrdersNungCurrentUser.toString());

  //       // Print the count of documents with the same UID as currentUID
  //       print('Number of documents with UID $currentUID: $parcelCount');

  //       // Your remaining code goes here

  //       return Container();
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // codOrdersNiCurrentUser();
    inputData();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: StreamBuilder<QuerySnapshot>(
          stream: _reference.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Something Went Wrong"),
              );
            }
            if (snapshot.hasData) {
              QuerySnapshot querySnapshot = snapshot.data!;

              List<QueryDocumentSnapshot> documents = querySnapshot.docs;
              // Convert data to List
              List<Parcels> parcels = documents
                  .map(
                    (e) => Parcels(
                      modeOfPayment: e['Mode of Payment'],
                      price: e['Price'],
                      productName: e['Product Name'],
                      trackingId: e['Tracking ID'],
                      delivered: e['Delivered'],
                      cashContainer: e['Cash Container'],
                      dateAdded: e['Date Added'],
                      timeAdded: e['Time Added'],
                      uid: e['UID'],
                    ),
                  )
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("parcels")
                    .where("UID", isEqualTo: currentUID)
                    .where("Mode of Payment", isEqualTo: "Cash on Delivery")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No data available');
                  }

                  var codCount = snapshot.data!.docs.length;
                  codOrders = codCount;

                  // Print COD count for verification (comment out in production)
                  print('COD documents: $codOrders');
                  // print(parcels.isEmpty);
                  // print(codOrders == 0);

                  print(codOrdersNungCurrentUser == 0);
                  return parcels.isEmpty || codOrders == 0
                      ? Center(
                          child: Text(
                            'Whoa! No COD Parcels arriving soon!\nClick + to start adding',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              color: Color(0xFF191970),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 16.0,
                              ),
                              // Container(
                              //   width: MediaQuery.of(context).size.width *
                              //       0.88,
                              //   color: Colors.grey.shade200,
                              //   child: SizedBox(
                              //     // color: Colors.grey.shade200,
                              //     child: Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.center,
                              //       children: [
                              //         Flexible(
                              //           flex: 2,
                              //           child: Padding(
                              //             padding:
                              //                 EdgeInsets.only(left: 12.0),
                              //             child: Image.asset(
                              //               'lib/images/ultrasonic sensor.png',
                              //               height: 80.0,
                              //               width: 70.0,
                              //               // color: Color(0xFF191970),
                              //             ),
                              //           ),
                              //         ),
                              //         // Flexible(
                              //         //   flex: 1,
                              //         //   child: Container(),
                              //         // ),
                              //         SizedBox(
                              //           width: 10.0,
                              //         ),
                              //         Flexible(
                              //           flex: 10,
                              //           child: Text(
                              //             "Ensure that the front barcode scanner is not triggered by ultrasonic sensor when deleting a parcel to retrieve cash placed in the machine",
                              //             textAlign: TextAlign.justify,
                              //             style: GoogleFonts.ubuntu(
                              //               fontSize: 12.0,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           width: 20.0,
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: parcels.length,
                                  itemBuilder: (context, index) {
                                    inputData();
                                    if (parcels[index].delivered == false &&
                                        parcels[index].modeOfPayment ==
                                            'Cash on Delivery' &&
                                        codOrders <= 4 &&
                                        parcels[index].uid == currentUID) {
                                      String standard_month = '${time.month}';
                                      String date =
                                          '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
                                      String timeAdded =
                                          '${time.hour}:${time.minute}';

                                      return Card(
                                        child: ListTile(
                                          title: Text(
                                            parcels[index].productName,
                                            style: const TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          isThreeLine: true,
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '₱ ${parcels[index].price!.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontFamily: 'OpenSans',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                // '${date} ${timeAdded}',
                                                '${parcels[index].dateAdded}    ${parcels[index].timeAdded}',
                                                style: const TextStyle(
                                                  fontFamily: 'OpenSans',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            radius: 25,
                                            child: Text(
                                              '${parcels[index].cashContainer![15]}',
                                              style: const TextStyle(
                                                fontFamily: 'BebasNeue',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Color(0xFF191970),
                                          ),
                                          trailing: SizedBox(
                                            width: 60.0,
                                            child: Row(
                                              children: [
                                                InkWell(
  child: const Icon(Icons.edit),
  onTap: () {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final Parcels parcel = parcels[index];
        cashContainerController.text = parcel.cashContainer!;
        productNameController.text = parcel.productName;
        priceController.text = parcel.price.toString();
        modePaymentController.text = parcel.modeOfPayment;

        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                'Update your Parcel',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 30.0,
                              color: Colors.grey.shade800,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Row(
                            children: [
                              Text(
                                'Tracking Number: ' + parcel.trackingId,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: productNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Product name is required!';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
                              return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
                            }
                            return null;
                          },
                          cursorColor: Colors.grey.shade600,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.0,
                          ),
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.shopping_bag, color: Color(0xFF191970)),
                            hintText: "Product Name",
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: fontfamily),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0, color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0, color: Color(0xFF191970)),
                            ),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            border: textFieldBorder(),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        DropdownButtonFormField<String>(
                          value: modePaymentController.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please choose your mode of payment';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMode = value!;
                              modePaymentController.text = selectedPaymentMode;
                              if (selectedPaymentMode == 'Non-Cash on Delivery') {
                                cashContainerController.text = '';
                                priceController.text = '0';
                              }
                              clearErrorMessage();
                            });
                          },
                          items: ['Cash on Delivery', 'Non-Cash on Delivery'].map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(
                                mode,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.0,
                                ),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            errorText: selectedPaymentModeError,
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: fontfamily),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0, color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0, color: Color(0xFF191970)),
                            ),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            hintText: 'Payment Mode',
                            border: textFieldBorder(),
                            prefixIcon: Icon(Icons.payment, color: Color(0xFF191970)),
                          ),
                        ),
                        if (selectedPaymentMode == 'Cash on Delivery') ...[
                          SizedBox(height: 10.0),
                          TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.grey.shade600,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.0,
                            ),
                            validator: validatePrice,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: fontfamily),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0, color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0, color: Color(0xFF191970)),
                              ),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              hintText: 'Price',
                              border: textFieldBorder(),
                              prefixIcon: Icon(Icons.attach_money, color: Color(0xFF191970)),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          StreamBuilder<List<String>>(
                            stream: getCashContainerStream(),
                            builder: (context, snapshot) {
                              return DropdownButtonFormField<String>(
                                value: cashContainerController.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose a cash container';
                                  }
                                  if (value != parcel.cashContainer && occupiedContainers.contains(value)) {
                                    return 'Cash Container $value is already occupied';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedCashContainer = value!;
                                    cashContainerController.text = selectedCashContainer;
                                    clearErrorMessage();
                                  });
                                },
                                items: ['Cash Container A', 'Cash Container B', 'Cash Container C', 'Cash Container D']
                                    .map((container) {
                                  return DropdownMenuItem(
                                    value: container,
                                    child: Text(
                                      container,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: fontfamily),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Color(0xFF191970)),
                                  ),
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  hintText: 'Cash Container',
                                  border: textFieldBorder(),
                                  prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF191970)),
                                ),
                              );
                            },
                          ),
                        ],
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool hasChanges = productNameController.text != parcel.productName ||
                                      priceController.text != parcel.price.toString() ||
                                      modePaymentController.text != parcel.modeOfPayment ||
                                      cashContainerController.text != parcel.cashContainer;

                                  if (!hasChanges) {
                                    return;
                                  }

                                  final querySnapshot = await FirebaseFirestore.instance
                                      .collection('parcels')
                                      .where('CashContainer', isEqualTo: cashContainerController.text)
                                      .get();

                                  bool isOccupiedByAnother = querySnapshot.docs.isNotEmpty &&
                                      querySnapshot.docs.first.id != parcel.id;

                                  if (isOccupiedByAnother && cashContainerController.text != parcel.cashContainer) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Cash Container ${cashContainerController.text} is already occupied.',
                                          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  bool userConfirmed = await showConfirmationDialog(
                                    context,
                                    parcel,
                                    modePaymentController.text,
                                    double.parse(priceController.text),
                                    cashContainerController.text,
                                    productNameController.text,
                                  );
                                  log(userConfirmed.toString());
                                  String naReceived = userConfirmed ? "naReceived" : "endenareceive";
                                  log(naReceived);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF191970),
                              ),
                              child: Text(
                                'Update Parcel',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  productNameController.text = parcel.productName;
                                  priceController.text = parcel.price.toString();
                                  selectedPaymentMode = parcel.modeOfPayment;
                                  selectedCashContainer = parcel.cashContainer!;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF191970),
                              ),
                              child: Text(
                                'Reset',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  letterSpacing: 1.5,
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
            );
          },
        );
      },
    );
  },
),

                                                // InkWell(
                                                //   child: const Icon(
                                                //     Icons.edit,
                                                //     // color: Colors.,
                                                //   ),
                                                //   onTap: () {
                                                //     showModalBottomSheet(
                                                //       isScrollControlled: true,
                                                //       context: context,
                                                //       builder: (BuildContext
                                                //           context) {
                                                //         final Parcels parcel =
                                                //             parcels[index];
                                                //         cashContainerController
                                                //                 .text =
                                                //             parcel
                                                //                 .cashContainer!;
                                                //         productNameController
                                                //                 .text =
                                                //             parcel.productName;
                                                //         priceController.text =
                                                //             parcel.price
                                                //                 .toString();
                                                //         modePaymentController
                                                //                 .text =
                                                //             parcel
                                                //                 .modeOfPayment;
                                                //         // trackingIDController
                                                //         //         .text =
                                                //         //     parcel.trackingId
                                                //         //         .toString();
                                                //         return StatefulBuilder(
                                                //           builder: (context,
                                                //               setState) {
                                                //             return SingleChildScrollView(
                                                //               child: Padding(
                                                //                 padding:
                                                //                     EdgeInsets
                                                //                         .only(
                                                //                   bottom: MediaQuery.of(
                                                //                           context)
                                                //                       .viewInsets
                                                //                       .bottom,
                                                //                 ),
                                                //                 child: Padding(
                                                //                   padding:
                                                //                       const EdgeInsets
                                                //                           .all(
                                                //                           20.0),
                                                //                   child: Form(
                                                //                     key:
                                                //                         _formKey,
                                                //                     child:
                                                //                         Column(
                                                //                       children: [
                                                //                         Row(
                                                //                           mainAxisAlignment:
                                                //                               MainAxisAlignment.spaceBetween,
                                                //                           children: [
                                                //                             Padding(
                                                //                               padding: const EdgeInsets.only(left: 3.0),
                                                //                               child: Text(
                                                //                                 'Update your Parcel',
                                                //                                 style: GoogleFonts.ubuntu(
                                                //                                   fontSize: 18,
                                                //                                   fontWeight: FontWeight.bold,

                                                //                                   // fontFamily: 'BebasNeue',
                                                //                                   letterSpacing: 1.5,
                                                //                                   color: Color(0xFF191970),
                                                //                                 ),
                                                //                               ),
                                                //                             ),
                                                //                             const SizedBox(
                                                //                               width: 10.0,
                                                //                             ),
                                                //                             Icon(
                                                //                               Icons.arrow_drop_down_outlined,
                                                //                               size: 30.0,
                                                //                               color: Colors.grey.shade800,
                                                //                             )
                                                //                           ],
                                                //                         ),
                                                //                         const SizedBox(
                                                //                           height:
                                                //                               15.0,
                                                //                         ),
                                                //                         TextFormField(
                                                //                           controller:
                                                //                               productNameController,
                                                //                           validator:
                                                //                               ((value) {
                                                //                             if (value == null ||
                                                //                                 value.isEmpty) {
                                                //                               return 'Product name is required!';
                                                //                             }
                                                //                             if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
                                                //                               return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
                                                //                             }
                                                //                             return null;
                                                //                           }),
                                                //                           cursorColor: Colors
                                                //                               .grey
                                                //                               .shade600,
                                                //                           style:
                                                //                               TextStyle(
                                                //                             color:
                                                //                                 Colors.grey.shade700,
                                                //                             fontWeight:
                                                //                                 FontWeight.w800,
                                                //                             fontSize:
                                                //                                 12.0,
                                                //                           ),
                                                //                           keyboardType:
                                                //                               TextInputType.name,
                                                //                           decoration:
                                                //                               InputDecoration(
                                                //                             prefixIcon:
                                                //                                 Icon(Icons.shopping_bag, color: Color(0xFF191970)),
                                                //                             hintText:
                                                //                                 "Product Name",
                                                //                             hintStyle:
                                                //                                 TextStyle(
                                                //                               color: Colors.grey.shade500,
                                                //                               fontFamily: fontfamily,
                                                //                             ),
                                                //                             enabledBorder:
                                                //                                 const OutlineInputBorder(
                                                //                               borderSide: BorderSide(
                                                //                                 width: 2.0,
                                                //                                 color: Colors.white,
                                                //                               ),
                                                //                             ),
                                                //                             focusedBorder:
                                                //                                 OutlineInputBorder(
                                                //                               borderSide: BorderSide(
                                                //                                 width: 2.0,
                                                //                                 color: Color(0xFF191970),
                                                //                               ),
                                                //                             ),
                                                //                             fillColor:
                                                //                                 Colors.grey.shade200,
                                                //                             filled:
                                                //                                 true,
                                                //                             border:
                                                //                                 textFieldBorder(),
                                                //                           ),
                                                //                         ),
                                                //                         const SizedBox(
                                                //                           height:
                                                //                               5.0,
                                                //                         ),
                                                //                         ButtonTheme(
                                                //                           child:
                                                //                               DropdownButtonFormField<String>(
                                                //                             value:
                                                //                                 // parcel.modeOfPayment,
                                                //                                 modePaymentController.text,
                                                //                             validator:
                                                //                                 (value) {
                                                //                               if (value == 'Select Mode of Payment') {
                                                //                                 selectedPaymentModeError = 'Please choose your mode of payment';
                                                //                                 clearErrorMessage();
                                                //                                 return selectedPaymentModeError;
                                                //                               }
                                                //                             },
                                                //                             onChanged:
                                                //                                 (value) {
                                                //                               setState(() {
                                                //                                 selectedPaymentMode = value!;
                                                //                                 modePaymentController.text = selectedPaymentMode;
                                                //                                 clearErrorMessage();
                                                //                               });
                                                //                             },
                                                //                             items: [
                                                //                               'Select Mode of Payment',
                                                //                               'Cash on Delivery',
                                                //                               'Non-Cash on Delivery'
                                                //                             ]
                                                //                                 .map((mode) => DropdownMenuItem(
                                                //                                       value: mode,
                                                //                                       child: Text(
                                                //                                         mode,
                                                //                                         style: TextStyle(
                                                //                                           color: Colors.grey.shade500,
                                                //                                           fontWeight: FontWeight.w800,
                                                //                                           fontSize: 12.0,
                                                //                                         ),
                                                //                                       ),
                                                //                                     ))
                                                //                                 .toList(),
                                                //                             decoration:
                                                //                                 InputDecoration(
                                                //                               errorText: selectedPaymentModeError,
                                                //                               hintStyle: TextStyle(
                                                //                                 color: Colors.grey.shade500,
                                                //                                 fontFamily: fontfamily,
                                                //                               ),
                                                //                               enabledBorder: const OutlineInputBorder(
                                                //                                 borderSide: BorderSide(
                                                //                                   width: 2.0,
                                                //                                   color: Colors.white,
                                                //                                 ),
                                                //                               ),
                                                //                               focusedBorder: OutlineInputBorder(
                                                //                                 borderSide: BorderSide(
                                                //                                   width: 2.0,
                                                //                                   color: Color(0xFF191970),
                                                //                                 ),
                                                //                               ),
                                                //                               fillColor: Colors.grey.shade200,
                                                //                               filled: true,
                                                //                               hintText: 'Payment Mode',
                                                //                               border: textFieldBorder(),
                                                //                               prefixIcon: Icon(Icons.payment, color: Color(0xFF191970)),
                                                //                             ),
                                                //                           ),
                                                //                         ),
                                                //                         if (selectedPaymentMode ==
                                                //                             'Cash on Delivery')
                                                //                           Column(
                                                //                             children: [
                                                //                               SizedBox(height: 10.0),
                                                //                               TextFormField(
                                                //                                 controller: priceController,
                                                //                                 keyboardType: TextInputType.number,
                                                //                                 cursorColor: Colors.grey.shade600,
                                                //                                 style: TextStyle(
                                                //                                   color: Colors.grey.shade700,
                                                //                                   fontWeight: FontWeight.w800,
                                                //                                   fontSize: 12.0,
                                                //                                 ),
                                                //                                 validator: validatePrice,
                                                //                                 decoration: InputDecoration(
                                                //                                   hintStyle: TextStyle(
                                                //                                     color: Colors.grey.shade500,
                                                //                                     fontFamily: fontfamily,
                                                //                                   ),
                                                //                                   enabledBorder: const OutlineInputBorder(
                                                //                                     borderSide: BorderSide(
                                                //                                       width: 2.0,
                                                //                                       color: Colors.white,
                                                //                                     ),
                                                //                                   ),
                                                //                                   focusedBorder: OutlineInputBorder(
                                                //                                     borderSide: BorderSide(
                                                //                                       width: 2.0,
                                                //                                       color: Color(0xFF191970),
                                                //                                     ),
                                                //                                   ),
                                                //                                   fillColor: Colors.grey.shade200,
                                                //                                   filled: true,
                                                //                                   hintText: 'Price',
                                                //                                   border: textFieldBorder(),
                                                //                                   prefixIcon: Icon(Icons.attach_money, color: Color(0xFF191970)),
                                                //                                 ),
                                                //                               ),
                                                //                               SizedBox(height: 10.0),
                                                //                               StreamBuilder<List<String>>(
                                                //                                 stream: getCashContainerStream(),
                                                //                                 builder: (context, snapshot) {
                                                //                                   return DropdownButtonFormField<String>(
                                                //                                     value: cashContainerController.text,
                                                //                                     validator: (value) {
                                                //                                       if (value == 'Select Cash Container') {
                                                //                                         selectedCashContainerError = 'Please choose a cash container';
                                                //                                         clearErrorMessage();
                                                //                                         return selectedCashContainerError;
                                                //                                       }
                                                //                                       if (occupiedContainers.contains(value)) {
                                                //                                         selectedCashContainerError = 'Cash Container $value is already occupied';
                                                //                                         clearErrorMessage();
                                                //                                         return selectedCashContainerError;
                                                //                                       }

                                                //                                       return null;
                                                //                                     },
                                                //                                     onChanged: (value) {
                                                //                                       setState(() {
                                                //                                         selectedCashContainer = value!;
                                                //                                         cashContainerController.text = selectedCashContainer;
                                                //                                         clearErrorMessage();
                                                //                                       });
                                                //                                     },
                                                //                                     items: [
                                                //                                       'Select Cash Container',
                                                //                                       'Cash Container A',
                                                //                                       'Cash Container B',
                                                //                                       'Cash Container C',
                                                //                                       'Cash Container D'
                                                //                                     ]
                                                //                                         .map((container) => DropdownMenuItem(
                                                //                                               value: container,
                                                //                                               child: Text(
                                                //                                                 container,
                                                //                                                 style: TextStyle(
                                                //                                                   color: Colors.grey.shade500,
                                                //                                                   fontWeight: FontWeight.w800,
                                                //                                                   fontSize: 12.0,
                                                //                                                 ),
                                                //                                               ),
                                                //                                             ))
                                                //                                         .toList(),
                                                //                                     decoration: InputDecoration(
                                                //                                       hintStyle: TextStyle(
                                                //                                         color: Colors.grey.shade500,
                                                //                                         fontFamily: fontfamily,
                                                //                                       ),
                                                //                                       enabledBorder: const OutlineInputBorder(
                                                //                                         borderSide: BorderSide(
                                                //                                           width: 2.0,
                                                //                                           color: Colors.white,
                                                //                                         ),
                                                //                                       ),
                                                //                                       focusedBorder: OutlineInputBorder(
                                                //                                         borderSide: BorderSide(
                                                //                                           width: 2.0,
                                                //                                           color: Color(0xFF191970),
                                                //                                         ),
                                                //                                       ),
                                                //                                       fillColor: Colors.grey.shade200,
                                                //                                       filled: true,
                                                //                                       hintText: 'Cash Container',
                                                //                                       border: textFieldBorder(),
                                                //                                       prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF191970)),
                                                //                                     ),
                                                //                                   );
                                                //                                 },
                                                //                               ),
                                                //                             ],
                                                //                           ),
                                                //                         const SizedBox(
                                                //                           height:
                                                //                               15.0,
                                                //                         ),
                                                //                         Row(
                                                //                           mainAxisAlignment:
                                                //                               MainAxisAlignment.spaceAround,
                                                //                           children: [
                                                //                             ElevatedButton(
                                                //                               onPressed: () async {
                                                //                                 // updated(parcel);
                                                //                                 bool userConfirmed = await showConfirmationDialog(context, parcel, modePaymentController.text, double.parse(priceController.text), cashContainerController.text, productNameController.text);
                                                //                                 log(userConfirmed.toString());
                                                //                                 String nareceived = await userConfirmed ? "nareceived" : "ende nareceive";
                                                //                                 log(nareceived);
                                                //                               },
                                                //                               style: ElevatedButton.styleFrom(
                                                //                                 foregroundColor: Colors.white,
                                                //                                 backgroundColor: Color(0xFF191970),
                                                //                               ),
                                                //                               child: Text(
                                                //                                 'Update Parcel',
                                                //                                 style: GoogleFonts.ubuntu(
                                                //                                   fontWeight: FontWeight.bold,
                                                //                                   fontSize: 15.0,
                                                //                                   // fontFamily: 'BebasNeue',
                                                //                                   letterSpacing: 1.5,
                                                //                                   // color: Colors.grey.shade600,
                                                //                                 ),
                                                //                               ),
                                                //                             ),
                                                //                             ElevatedButton(
                                                //                               onPressed: () => {
                                                //                                 setState(
                                                //                                   () {
                                                //                                     productNameController.text = parcel.productName;
                                                //                                     priceController.text = parcel.price.toString();
                                                //                                     selectedPaymentMode = parcel.modeOfPayment;
                                                //                                     selectedCashContainer = parcel.cashContainer!;
                                                //                                     // modePaymentController.text = 'Select Mode of Payment',
                                                //                                     // cashContainerController.text = 'Select Cash Container',
                                                //                                   },
                                                //                                 )
                                                //                               },
                                                //                               style: ElevatedButton.styleFrom(
                                                //                                 backgroundColor: Colors.white,
                                                //                                 foregroundColor: Color(0xFF191970),
                                                //                               ),
                                                //                               child: Text(
                                                //                                 'Reset',
                                                //                                 style: GoogleFonts.ubuntu(
                                                //                                   fontWeight: FontWeight.bold,
                                                //                                   fontSize: 15.0,
                                                //                                   letterSpacing: 1.5,
                                                //                                 ),
                                                //                               ),
                                                //                             ),
                                                //                           ],
                                                //                         ),
                                                //                       ],
                                                //                     ),
                                                //                   ),
                                                //                 ),
                                                //               ),
                                                //             );
                                                //           },
                                                //         );
                                                //       },
                                                //     );
                                                //   },
                                                // ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                InkWell(
                                                  child:
                                                      const Icon(Icons.delete),
                                                  onTap: () {
                                                    final parcel =
                                                        parcels[index];
                                                    // _reference
                                                    //     .doc(parcels[index]
                                                    //         .trackingId)
                                                    //     .delete();
                                                    // Navigator.pushReplacement(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         ParcelTabs(),
                                                    //   ),
                                                    // );

                                                    _showDeleteConfirmationDialog(
                                                        parcel, index, context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 100.0,
                              ),
                            ],
                          ),
                        );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future openCashContainerToGetMoney(
      OpenCashContainer openCashContainer, BuildContext context) async {
    final openCashContainerRef =
        FirebaseFirestore.instance.collection('open').doc("CashContainer");
    openCashContainer.id = openCashContainerRef.id;
    final open = openCashContainer.toJson();
    await openCashContainerRef.set(open).whenComplete(() => null);
  }
}
