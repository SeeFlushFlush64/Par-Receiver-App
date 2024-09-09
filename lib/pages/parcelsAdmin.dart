import 'package:modernlogintute/pages/COD_tab.dart';
import 'package:modernlogintute/pages/NON_COD_tab.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/parcels_added.dart';
import 'package:modernlogintute/userTabs/parcels_received.dart';


class ParcelsAdmin extends StatefulWidget {
  const ParcelsAdmin({super.key});

  @override
  State<ParcelsAdmin> createState() => _ParcelsAdminState();
}

class _ParcelsAdminState extends State<ParcelsAdmin> {
  List<String> modeOfPayments = [
    "Stored",
    "Extracted",
  ];

  Widget _getBody(current) {
    return current == 0 ? ParcelsAdded() : ParcelsReceived();
  }

  int current = 0;
  double changePositionOfLine(current) {
    switch (current) {
      case 0:
        return 70;
      case 1:
        return 200;
      default:
        return 40;
    }
  }

  double changeContainerWidth(current) {
    switch (current) {
      case 0:
        return 115;
      case 1:
        return 135;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'PARCELS',
            style: GoogleFonts.ubuntu(
              color: Color(0xFF191970),
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey.shade50,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    Container(
                      width: size.width,
                      height: size.height * 0.05,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.04,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(modeOfPayments.length,
                                    (index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        current = index;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 30 : 45,
                                          right:
                                              index == modeOfPayments.length - 1
                                                  ? 20
                                                  : 35,
                                          top: 7),
                                      child: Text(
                                        modeOfPayments[index],
                                        style: GoogleFonts.ubuntu(
                                            color: Color(0xFF191970),
                                            fontSize:
                                                current == index ? 16 : 14,
                                            fontWeight: current == index
                                                ? FontWeight.bold
                                                : FontWeight.w300),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            bottom: 0,
                            left: changePositionOfLine(current),
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: Duration(milliseconds: 500),
                            child: AnimatedContainer(
                              curve: Curves.fastLinearToSlowEaseIn,
                              width: changeContainerWidth(current),
                              height: size.height * 0.008,
                              duration: Duration(
                                milliseconds: 500,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFF191970)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _getBody(current),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
