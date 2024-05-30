import 'package:driver_app/AllScreens/canInfoScreen.dart';
import 'package:driver_app/configMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/AllScreens/loginScreen.dart';
import 'package:driver_app/AllScreens/mainscreen.dart';
import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:driver_app/DataHandler/appData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');
DatabaseReference driverRef = FirebaseDatabase.instance.ref().child('drivers');
DatabaseReference newRequestRef = FirebaseDatabase.instance.ref().child('Ride Requests');
DatabaseReference rideRequestRef = FirebaseDatabase.instance.ref().child("drivers").child(currentfirebaseUser.uid).child("newRide");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'DriveEase | Driver App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:
            currentUser == null ? LoginScreen.idScreen : MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => const LoginScreen(),
          MainScreen.idScreen: (context) => const MainScreen(),
          CanInfoScreen.idScreen: (context) => CanInfoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
