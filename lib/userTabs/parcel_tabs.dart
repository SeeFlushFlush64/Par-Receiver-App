import 'package:modernlogintute/pages/COD_tab.dart';
import 'package:modernlogintute/pages/NON_COD_tab.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcelTabs extends StatefulWidget {
  const ParcelTabs({super.key});

  @override
  State<ParcelTabs> createState() => _ParcelTabsState();
}

class _ParcelTabsState extends State<ParcelTabs> {
  List<String> modeOfPayments = [
    "Cash on Delivery",
    "Non-Cash on Delivery",
  ];
  Widget _getBody(current) {
    return current == 0 ? COD_tab() : NON_COD_tab();
  }

  int current = 0;
  double changePositionOfLine(current) {
    switch (current) {
      case 0:
        return MediaQuery.sizeOf(context).width * 0.1;
      case 1:
        return MediaQuery.sizeOf(context).width * 0.46;
      default:
        return 40;
    }
  }

  double changeContainerWidth(current) {
    switch (current) {
      case 0:
        return MediaQuery.sizeOf(context).width * 0.33;
      case 1:
        return MediaQuery.sizeOf(context).width * 0.4;
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
                      // color: Colors.red,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: size.width * 0.075,
                            right: 0,
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.04,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                itemCount: modeOfPayments.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        current = index;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 10 : 25, top: 7),
                                      child: Text(
                                        modeOfPayments[index],
                                        style: GoogleFonts.ubuntu(
                                            color: Color(0xFF191970),
                                            fontSize: current == index
                                                ? size.height * 0.02
                                                : size.height * 0.017,
                                            fontWeight: current == index
                                                ? FontWeight.bold
                                                : FontWeight.w300),
                                      ),
                                    ),
                                  );
                                },
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
                              // margin: EdgeInsets.only(left: 10),
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
