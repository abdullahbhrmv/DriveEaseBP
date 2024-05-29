import 'dart:async';
import 'package:driver_app/Notifications/pushNotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver_app/configMap.dart';

class HomeTabPage extends StatefulWidget {
  HomeTabPage({Key? key}) : super(key: key);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.015137, 28.979530), // Coordinates for Istanbul
    zoom: 14.4746,
  );

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  late GoogleMapController newGoogleMapController;

  late StreamSubscription<Position> homeTabPageStreamSubscription;

  late Position currentPosition;

  var geoLocator = Geolocator();

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  DatabaseReference? rideRequestRef;

  String driverStatusText = "Şimdi Çevrimdışısiniz - Çevrimiçi Olun";

  @override
  void initState() {
    super.initState();
    currentfirebaseUser = FirebaseAuth.instance.currentUser!;
    getCurrentDriverInfo();
    locatePosition(context);
  }

  Future<void> locatePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = (await FirebaseAuth.instance.currentUser)!;
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
          },
        ),
        // online offline driver Container
        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.9, // Adjust width as needed
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: driverStatusColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  onPressed: () {
                    if (!isDriverAvailable) {
                      makeDriverOnlineNow();
                      getLocationLiveUpdates();

                      setState(() {
                        driverStatusColor = Colors.green;
                        driverStatusText = "Çevrimiçi";
                        isDriverAvailable = true;
                      });
                      displayToastMessage("Şu anda Çevrimiçisiniz", context);
                    } else {
                      makeDriverOfflineNow();

                      setState(() {
                        driverStatusColor = Colors.black;
                        driverStatusText =
                            "Şimdi Çevrimdışısiniz - Çevrimiçi Olun";
                        isDriverAvailable = false;
                      });
                      displayToastMessage("Şu anda Çevrimdışınız", context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            driverStatusText,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 26.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    if (currentfirebaseUser != null && currentPosition != null) {
      Geofire.initialize("availabeDrivers");
      Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude,
          currentPosition.longitude);

      rideRequestRef = FirebaseDatabase.instance
          .reference()
          .child("drivers/${currentfirebaseUser!.uid}/rideRequest");
      rideRequestRef!.set("waiting");
    } else {
      print('currentfirebaseUser or currentPosition is null');
    }
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable) {
        Geofire.setLocation(
            currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void displayToastMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRef!.onDisconnect();
    rideRequestRef!.remove();
    rideRequestRef = null;
  }
}
