import 'package:modernlogintute/userTabs/about.dart';
import 'package:modernlogintute/userTabs/transactions.dart';
import 'package:modernlogintute/userTabs/home.dart';
import 'package:modernlogintute/pages/monitor.dart';
import 'package:modernlogintute/userTabs/parcel_tabs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modernlogintute/userTabs/add_pickMoP.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:web_socket_channel/io.dart';

class BotNavController extends StatefulWidget {
  const BotNavController({super.key});

  @override
  State<BotNavController> createState() => _BotNavControllerState();
}

class _BotNavControllerState extends State<BotNavController> {
  final _controller = PersistentTabController(initialIndex: 0);
  List<Widget> _tabs() {
    return [
      // Text('Home'),
      // Text('Parcels'),
      // Text('History'),
      // Text('Monitor'),
      Home(controller: _controller),
      ParcelTabs(),
      AddPickMoP(),
      Transactions(),
      // Monitor(
      //   gcpChannel: IOWebSocketChannel.connect('ws://35.197.152.96:65080'),
      //   personalChannel: IOWebSocketChannel.connect('ws://192.168.60.161:8888'),
      // ),
      About(),
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
        title: "Parcels",
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        inactiveColorPrimary: Colors.grey.shade400,
        activeColorPrimary: Color(0xFF191970),
        icon: Icon(Icons.shopping_bag_outlined),
      ),
      PersistentBottomNavBarItem(
        title: "Add",
        icon: Icon(
          Icons.add,
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
      // PersistentBottomNavBarItem(
      //   title: "Monitor",
      //   textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
      //   inactiveColorPrimary: Colors.grey.shade400,
      //   activeColorPrimary: Color(0xFF191970),
      //   icon: Icon(Icons.videocam_outlined),
      // ),
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
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when the keyboard appears.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'true' to hide bottom navigation bar when keyboard appears.
      // decoration: NavBarDecoration(
      //   borderRadius: BorderRadius.circular(10.0),
      //   colorBehindNavBar: Colors.white,
      // ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}
