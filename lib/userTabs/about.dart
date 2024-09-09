import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool isTypewritingComplete = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor:
                            0.99, // Adjust this value to slightly overcrop the image
                        child: Image.asset(
                          'lib/images/background-about-par-receiver.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF191970).withOpacity(
                                0.5), // Light blue shade with opacity
                            Color(0xFF191970), // Blue color below the image
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.sizeOf(context).height * 0.07,
                    left: MediaQuery.sizeOf(context).width * 0.02,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'lib/images/par_receiver_logo.png',
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Text(
                              "Par-Receiver",
                              style: GoogleFonts.ubuntu(
                                color: Colors.grey.shade50,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03),
                          child: Row(
                            children: [
                              DefaultTextStyle(
                                style: GoogleFonts.ubuntu(
                                  color: Colors.grey.shade100,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: TypewriterAnimatedTextKit(
                                  repeatForever: false,
                                  speed: Duration(milliseconds: 100),
                                  totalRepeatCount: 1,
                                  text: ['Receive parcels.'],
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade100,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.sizeOf(context).height * 0.02,
                    left: MediaQuery.sizeOf(context).width * 0.02,
                    right: 0,
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: Future.delayed(Duration(
                              seconds: 2)), // Delay before typing "Whenever."
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(); // Placeholder while waiting
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                child: Row(
                                  children: [
                                    DefaultTextStyle(
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.grey.shade100,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      child: TypewriterAnimatedTextKit(
                                        repeatForever: false,
                                        speed: Duration(milliseconds: 100),
                                        totalRepeatCount: 1,
                                        text: ['Whenever.'],
                                        textStyle: TextStyle(
                                          color: Colors.grey.shade100,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    FutureBuilder(
                                      future: Future.delayed(Duration(
                                          seconds:
                                              2)), // Delay before typing "Wherever."
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(); // Placeholder while waiting
                                        } else {
                                          return DefaultTextStyle(
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.grey.shade100,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            child: TypewriterAnimatedTextKit(
                                              repeatForever: false,
                                              speed:
                                                  Duration(milliseconds: 100),
                                              totalRepeatCount: 1,
                                              text: ['Wherever.'],
                                              textStyle: TextStyle(
                                                color: Colors.grey.shade100,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.035,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 7,
              child: Container(
                color: Color(0xFF191970),
                child: Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.sizeOf(context).height * 0.025,
                      bottom: MediaQuery.sizeOf(context).height * 0.275,
                      right: MediaQuery.sizeOf(context).width * 0.05,
                      left: MediaQuery.sizeOf(context).width * 0.05,
                      child: Card(
                        color: Color.fromARGB(255, 49, 49, 95),
                        child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.sizeOf(context).height * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Features of Par-Receiver?",
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height * 0.022,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/notif_icon.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Realtime notifications",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/alarm_icon.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Built with reliable sensors",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/cash_icon.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Track your parcels' cash balance",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "",
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height * 0.017,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.01,
                    // ),
                    Positioned(
                      top: MediaQuery.sizeOf(context).height * 0.29,
                      // bottom: MediaQuery.sizeOf(context).height * 0.00002,
                      right: MediaQuery.sizeOf(context).width * 0.05,
                      left: MediaQuery.sizeOf(context).width * 0.05,
                      child: Card(
                        color: Color.fromARGB(255, 49, 49, 95),
                        child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.sizeOf(context).height * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Why use Par-Receiver?",
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height * 0.022,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/buyer_icon.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Buyers don't miss parcel deliveries",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.015,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/seller_icon.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Sellers get the payment and\nprevent Return to Sender (RTS)",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.015,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.015,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/images/delivery-man.png",
                                    color: Colors.white,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.03,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.06,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.03,
                                  ),
                                  Text(
                                    "Delivery riders don't need to redeliver",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.sizeOf(context).height *
                                              0.015,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "",
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.sizeOf(context).height * 0.017,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
