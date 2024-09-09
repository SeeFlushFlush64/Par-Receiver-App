import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/userTabs/requiredfields.dart';

class NON_COD_tab extends StatefulWidget {
  NON_COD_tab({super.key});

  @override
  State<NON_COD_tab> createState() => _NON_COD_tabState();
}

class _NON_COD_tabState extends State<NON_COD_tab> {
  int nonCodOrders = 0;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('parcels');
  var time = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String fontfamily = "Open Sans";
  String currentUID = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    // print(currentUID);
    // here you write the codes to input the data into firestore
  }

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController cashContainerController = TextEditingController();
  TextEditingController modePaymentController = TextEditingController();
  TextEditingController trackingIDController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  String selectedPaymentMode = 'Non-Cash on Delivery';
  String selectedCashContainer = 'Select Cash Container';

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
                      "This process cannot be undone.\nAre you sure you want to delete this parcel?",
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

  @override
  Widget build(BuildContext context) {
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
                      // price: e['Price'],
                      productName: e['Product Name'],
                      trackingId: e['Tracking ID'],
                      delivered: e['Delivered'],
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
                    .where("Mode of Payment", isEqualTo: "Non-Cash on Delivery")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    // return Text('No data available');
                  }

                  var nonCodCount = snapshot.data!.docs.length;
                  inputData();
                  log("UID: " + currentUID);
                  log("Non-COD documents: " + nonCodCount.toString());
                  nonCodOrders = nonCodCount;
                  // setState(() {
                  //   _nonCodOrders =
                  //       nonCodCount; // Update _codOrders using setState()
                  //   log('COD documents: $nonCodCount');
                  // });

                  print('Non-COD documents: $nonCodOrders');

                  // Print COD count for verification (comment out in production)

                  return parcels.isEmpty || nonCodOrders == 0
                      ? Center(
                          child: Text(
                            'Whoa! No Non-COD Parcels arriving soon!\nClick + to start adding',
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
                            children: [
                              Container(
                                // margin: EdgeInsets.only(bottom: 200.0),
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: parcels.length,
                                  itemBuilder: (context, index) {
                                    if (parcels[index].delivered == false &&
                                        parcels[index].modeOfPayment ==
                                            'Non-Cash on Delivery' &&
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
                                          // isThreeLine: true,
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text(
                                              //   '₱ ${parcels[index].price!.toStringAsFixed(2)}',
                                              //   style: const TextStyle(
                                              //     fontFamily: 'OpenSans',
                                              //     fontWeight: FontWeight.w600,
                                              //   ),
                                              // ),
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
                                              '1',
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
                                                    child: const Icon(
                                                      Icons.edit,
                                                      // color: Colors.,
                                                    ),
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          final Parcels parcel =
                                                              parcels[index];
                                                          cashContainerController
                                                              .text = parcel
                                                                      .cashContainer ==
                                                                  null
                                                              ? "Select Cash Container"
                                                              : parcel
                                                                  .cashContainer!;
                                                          productNameController
                                                                  .text =
                                                              parcel
                                                                  .productName;
                                                          priceController
                                                              .text = parcel
                                                                      .price ==
                                                                  null
                                                              ? "0"
                                                              : parcel.price
                                                                  .toString();
                                                          modePaymentController
                                                                  .text =
                                                              parcel
                                                                  .modeOfPayment;
                                                          // trackingIDController
                                                          //         .text =
                                                          //     parcel.trackingId
                                                          //         .toString();
                                                          return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return SingleChildScrollView(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                    bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            20.0),
                                                                    child: Form(
                                                                      key:
                                                                          _formKey,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 3.0),
                                                                                child: Text(
                                                                                  'Update your Parcel',
                                                                                  style: GoogleFonts.ubuntu(
                                                                                    fontSize: 18,
                                                                                    fontWeight: FontWeight.bold,

                                                                                    // fontFamily: 'BebasNeue',
                                                                                    letterSpacing: 1.5,
                                                                                    color: Color(0xFF191970),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10.0,
                                                                              ),
                                                                              Icon(
                                                                                Icons.arrow_drop_down_outlined,
                                                                                size: 30.0,
                                                                                color: Colors.grey.shade800,
                                                                              )
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                15.0,
                                                                          ),
                                                                          TextFormField(
                                                                            controller:
                                                                                productNameController,
                                                                            validator:
                                                                                ((value) {
                                                                              if (value == null || value.isEmpty) {
                                                                                return 'Product name is required!';
                                                                              }
                                                                              if (!RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(value)) {
                                                                                return 'Invalid product name. Only alphanumeric, spaces, and dashes are allowed.';
                                                                              }
                                                                              return null;
                                                                            }),
                                                                            cursorColor:
                                                                                Colors.grey.shade600,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey.shade700,
                                                                              fontWeight: FontWeight.w800,
                                                                              fontSize: 12.0,
                                                                            ),
                                                                            keyboardType:
                                                                                TextInputType.name,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              prefixIcon: Icon(Icons.shopping_bag, color: Color(0xFF191970)),
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
                                                                            height:
                                                                                5.0,
                                                                          ),
                                                                          ButtonTheme(
                                                                            child:
                                                                                DropdownButtonFormField<String>(
                                                                              value:
                                                                                  // parcel.modeOfPayment,
                                                                                  modePaymentController.text,
                                                                              validator: (value) {
                                                                                if (value == 'Select Mode of Payment') {
                                                                                  selectedPaymentModeError = 'Please choose your mode of payment';
                                                                                  clearErrorMessage();
                                                                                  return selectedPaymentModeError;
                                                                                }
                                                                              },
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  selectedPaymentMode = value!;
                                                                                  modePaymentController.text = selectedPaymentMode;
                                                                                  clearErrorMessage();
                                                                                });
                                                                              },
                                                                              items: [
                                                                                'Select Mode of Payment',
                                                                                'Cash on Delivery',
                                                                                'Non-Cash on Delivery'
                                                                              ]
                                                                                  .map((mode) => DropdownMenuItem(
                                                                                        value: mode,
                                                                                        child: Text(
                                                                                          mode,
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade500,
                                                                                            fontWeight: FontWeight.w800,
                                                                                            fontSize: 12.0,
                                                                                          ),
                                                                                        ),
                                                                                      ))
                                                                                  .toList(),
                                                                              decoration: InputDecoration(
                                                                                errorText: selectedPaymentModeError,
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
                                                                                hintText: 'Payment Mode',
                                                                                border: textFieldBorder(),
                                                                                prefixIcon: Icon(Icons.payment, color: Color(0xFF191970)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          if (selectedPaymentMode ==
                                                                              'Cash on Delivery')
                                                                            Column(
                                                                              children: [
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
                                                                                        if (value == 'Select Cash Container') {
                                                                                          selectedCashContainerError = 'Please choose a cash container';
                                                                                          clearErrorMessage();
                                                                                          return selectedCashContainerError;
                                                                                        }
                                                                                        if (occupiedContainers.contains(value)) {
                                                                                          selectedCashContainerError = 'Cash Container $value is already occupied';
                                                                                          clearErrorMessage();
                                                                                          return selectedCashContainerError;
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
                                                                                                    fontSize: 12.0,
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
                                                                                        prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF191970)),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          const SizedBox(
                                                                            height:
                                                                                15.0,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                onPressed: () {
                                                                                  String standard_month = '${time.month}';
                                                                                  String date = '${monthNames.elementAt(int.parse(standard_month) - 1)} ${time.day}, ${time.year}';
                                                                                  String timeAdded = '${time.hour}:${time.minute}';
                                                                                  Parcels updatedParcels = Parcels(
                                                                                    dateAdded: date,
                                                                                    timeAdded: timeAdded,
                                                                                    modeOfPayment: modePaymentController.text,
                                                                                    price: double.parse(priceController.text),
                                                                                    cashContainer: cashContainerController.text,
                                                                                    productName: productNameController.text,
                                                                                    trackingId: parcel.trackingId,
                                                                                    delivered: false,
                                                                                    uid: currentUID,
                                                                                  );
                                                                                  final collectionReference = FirebaseFirestore.instance.collection('parcels');
                                                                                  collectionReference.doc(updatedParcels.trackingId).update(updatedParcels.toJson()).whenComplete(
                                                                                    () {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(
                                                                                          content: Text(
                                                                                            "Parcel updated",
                                                                                            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                          backgroundColor: Colors.green,
                                                                                        ),
                                                                                      );
                                                                                      log('Parcel updated');
                                                                                      Navigator.pushReplacement(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => ParcelTabs(),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
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
                                                                                    // fontFamily: 'BebasNeue',
                                                                                    letterSpacing: 1.5,
                                                                                    // color: Colors.grey.shade600,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              ElevatedButton(
                                                                                onPressed: () => {
                                                                                  productNameController.text = parcel.productName,
                                                                                  priceController.text = "0",
                                                                                  selectedPaymentMode = parcel.modeOfPayment,
                                                                                  // selectedCashContainer = parcel.cashContainer!,
                                                                                  // modePaymentController.text = 'Select Mode of Payment',
                                                                                  // cashContainerController.text = 'Select Cash Container',
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
                                                    }),
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
                                    // else if (parcels[index].delivered == true) {
                                    //   History(
                                    //       productName: parcels[index].productName,
                                    //       parcelsDelivered: ++parcelsReceived,
                                    //       price: parcels[index].price,
                                    //       modeOfPayment: parcels[index].modeOfPayment);
                                    // }
                                    return Container();
                                  },
                                ),
                                // ElevatedButton(
                                //   onPressed: History().viewReceivedParcels,
                                //   child: Text(
                                //     "Check Received Parcels",
                                //   ),
                                // ),
                              ),
                              SizedBox(
                                height: 100.0,
                              ),
                              // AlertDialog(
                              //   title: Text(codCount().toString()),
                              // )
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
            // return Container();
          },
          // child: _getBody(),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => AddParcels(),
        //   backgroundColor: Colors.grey.shade600,
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }

  // Widget _getBody(parcels) {

  // }
}
