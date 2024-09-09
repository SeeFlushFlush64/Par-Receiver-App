import 'package:modernlogintute/adminTabs/adminHome.dart';
import 'package:modernlogintute/adminTabs/adminScanToExtract.dart';
import 'package:modernlogintute/adminTabs/adminTransactions.dart';
import 'package:modernlogintute/adminTabs/appUsers.dart';
import 'package:modernlogintute/userTabs/about.dart';
import 'package:modernlogintute/userTabs/add_pickMoP.dart';
import 'package:modernlogintute/userTabs/transactions.dart';
import 'package:modernlogintute/userTabs/home.dart';
import 'package:modernlogintute/pages/monitor.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:web_socket_channel/io.dart';

class AdminBotNavController extends StatefulWidget {
  const AdminBotNavController({super.key});
  @override
  _AdminBotNavControllerState createState() => _AdminBotNavControllerState();
  // @override
  // State<AdminBotNavController> createState() => _AdminBotNavControllerState();
}

class _AdminBotNavControllerState extends State<AdminBotNavController> {
  // final controller = PersistentTabController(initialIndex: 0);
  late PersistentTabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _tabs() {
    return [
      // Text('Home'),
      // Text('Parcels'),
      // Text('History'),
      // Text('Monitor'),
      AdminHome(
          // controller: _controller,
          ),
      AppUsers(),
      AdminScanToExtract(),
      AdminTransactions(),
      About(),
      // Monitor(
      //   gcpChannel: IOWebSocketChannel.connect('ws://35.197.152.96:65080'),
      //   personalChannel: IOWebSocketChannel.connect('ws://192.168.60.161:8888'),
      // ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItem() {
    return [
      PersistentBottomNavBarItem(
        title: "Home",
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
        icon: Icon(Icons.home_outlined),
      ),
      PersistentBottomNavBarItem(
        title: "Users",
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
        icon: Icon(Icons.person_outlined),
      ),
      PersistentBottomNavBarItem(
        title: "Scan",
        icon: Icon(
          Icons.qr_code,
          color: Color(0xFF191970),
        ),
        // inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
      ),
      PersistentBottomNavBarItem(
        title: "Transactions",
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
        icon: Icon(Icons.history),
      ),
      PersistentBottomNavBarItem(
        title: "About",
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
        icon: Icon(Icons.info),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      backgroundColor: Colors.grey.shade50,
      padding: NavBarPadding.all(10.0),
      screens: _tabs(),
      items: _navBarItem(),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(1.0),
      ),
      navBarStyle: NavBarStyle.style6,
      // resizeToAvoidBottomInset:
      //     true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      // stateManagement: true, // Default is true.
      // hideNavigationBarWhenKeyboardShows:
      //     true, // Recommended to set 'true' to hide the nav bar when keyboard appears. Default is true.
      // popAllScreensOnTapOfSelectedTab: true,
      // popActionScreens: PopActionScreensType.all,
      // itemAnimationProperties: ItemAnimationProperties(
      //   // Navigation Bar's items animation properties.
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.ease,
      // ),
      // screenTransitionAnimation: ScreenTransitionAnimation(
      //   // Screen transition animation on change of selected tab.
      //   animateTabTransition: true,
      //   curve: Curves.ease,
      //   duration: Duration(milliseconds: 200),
      // ),
      // onItemSelected: (int index) {
      //   if (index == 0) {
      //     // Navigate to AdminHome if the "Home" tab is selected
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => AdminHome(
      //           controller: _controller,
      //         ),
      //       ),
      //     );
      //   }
      // },
    );
  }
}
