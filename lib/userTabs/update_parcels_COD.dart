import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/userTabs/requiredfields.dart';

class UpdateCODParcels {
  String currentUID = "";
  final context;
  final Parcels parcel;
  final fontfamily;
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController modePaymentController = TextEditingController();
  TextEditingController trackingIDController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController timeAddedController = TextEditingController();
  UpdateCODParcels(
    this.context,
    this.fontfamily,
    this.parcel,
    // this.productNameController,
    // this.priceController,
    // this.modePaymentController,
    // this.trackingIDController,
  );

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    currentUID = uid!;
    // print(currentUID);
    // here you write the codes to input the data into firestore
  }

  updatecreated() => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          productNameController.text = parcel.productName;
          // priceController.text = parcel.price.toString();
          modePaymentController.text = parcel.modeOfPayment;
          trackingIDController.text = parcel.trackingId.toString();
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            'Update your Parcel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                              letterSpacing: 1.5,
                              color: Colors.grey.shade600,
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
                      height: 15.0,
                    ),
                    TextField(
                      controller: productNameController,
                      cursorColor: Colors.grey.shade600,
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Product Name",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: fontfamily,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextField(
                      controller: priceController,
                      cursorColor: Colors.grey.shade600,
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Price",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: fontfamily,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextField(
                      controller: modePaymentController,
                      cursorColor: Colors.grey.shade600,
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Mode of Payment",
                        hintStyle: TextStyle(
                          fontFamily: fontfamily,
                          color: Colors.grey.shade500,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextField(
                      controller: trackingIDController,
                      cursorColor: Colors.grey.shade600,
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Tracking ID",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: fontfamily,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Parcels updatedParcels = Parcels(
                              dateAdded: dateAddedController.text,
                              modeOfPayment: modePaymentController.text,
                              // price: int.parse(priceController.text),

                              productName: productNameController.text,
                              trackingId: parcel.trackingId,
                              delivered: false,
                              timeAdded: timeAddedController.text,
                              uid: currentUID,
                            );
                            final collectionReference = FirebaseFirestore
                                .instance
                                .collection('parcels');
                            collectionReference
                                .doc(updatedParcels.trackingId)
                                .update(updatedParcels.toJson())
                                .whenComplete(
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Parcel updated"),
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
                            backgroundColor: Colors.grey.shade600,
                          ),
                          child: const Text(
                            'Update Parcel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              fontFamily: 'BebasNeue',
                              letterSpacing: 1.5,
                              // color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => {
                            productNameController.text = "",
                            priceController.text = "",
                            modePaymentController.text = "",
                            trackingIDController.text = "",
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              fontFamily: 'BebasNeue',
                              letterSpacing: 1.5,
                              // color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
