import 'package:driver_app/tabsPages/earningsTabPage.dart';
import 'package:driver_app/tabsPages/homeTabPage.dart';
import 'package:driver_app/tabsPages/profileTabPage.dart';
import 'package:driver_app/tabsPages/ratingTabPages.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver_app/configMap.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String idScreen = "mainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);

    if (FirebaseAuth.instance.currentUser != null) {
      currentfirebaseUser = FirebaseAuth.instance.currentUser!;
      var rideRequestRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(currentfirebaseUser.uid)
          .child("newRide");
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningsTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.creditCard),
            label: "Kazanç",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.star),
            label: "Değerlendirme",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.person),
            label: "Profil",
          ),
        ],
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12.0),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
