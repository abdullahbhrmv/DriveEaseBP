import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/Assistants/geoFireAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/directDetails.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rider_app/Models/nearbyAvailableDrivers.dart';
import 'package:rider_app/configMap.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const String idScreen = "mainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;
  late DatabaseReference rideRequestRef;
  BitmapDescriptor? nearByIcon;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingofMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  void savedRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp?.latitude.toString(),
      "longitude": pickUp?.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff?.latitude.toString(),
      "longitude": dropOff?.longitude.toString(),
    };

    Map rideinfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_name": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp?.placeName,
      "dropoff_address": dropOff?.placeName,
    };

    rideRequestRef.set(rideinfoMap);
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230;
      drawerOpen = true;
    });

    savedRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0.0;
      requestRideContainerHeight = 0.0;
      bottomPaddingofMap = 230.0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();

      locatePosition(context);
    });
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Please wait...",
      ),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details!;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(details!.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolylinePointsResult.isNotEmpty) {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: Colors.pink,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatLng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: const MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: const CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: const CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void displayRideDetailsContainerHeight() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240;
      bottomPaddingofMap = 230;
      drawerOpen = false;
    });
  }

  void locatePosition(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinatedAddress(position, context);
    print("This is your Address :: " + address);

    initGeoFireListner();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.015137, 28.979530), // Coordinates for Istanbul
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    tripDirectionDetails = DirectionDetails();
    AssistantMethods.getCurrentOnlineInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 165.0,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      const SizedBox(width: 16.0),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand-Bold"),
                          ),
                          SizedBox(height: 6.0),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              const ListTile(
                leading: Icon(FontAwesomeIcons.history),
                title: Text(
                  "Ride History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(FontAwesomeIcons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(FontAwesomeIcons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false);
                },
                child: const ListTile(
                  leading: Icon(FontAwesomeIcons.signOutAlt),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingofMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingofMap = 300.0;
              });
              locatePosition(context);
            },
          ),
          // HamburgerButton for Drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20.0,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // Search bar for finding places
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: searchContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6.0),
                    const Text(
                      "Merhaba,",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Brand-Regular",
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                        if (res == "obtainDirection") {
                          displayRideDetailsContainerHeight();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Nereye gitmek istersiniz?",
                                style: TextStyle(
                                  fontFamily: "Brand-Regular",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<AppData>(context).pickUpLocation !=
                                      null
                                  ? Provider.of<AppData>(context)
                                      .pickUpLocation!
                                      .placeName
                                  : "Ev",
                              style: const TextStyle(
                                fontFamily: "Brand-Regular",
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Konumunuz",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.0,
                                  fontFamily: "Brand-Regular"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const DividerWidget(),
                    const SizedBox(height: 16.0),
                    const Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "İş",
                              style: TextStyle(
                                fontFamily: "Brand-Regular",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              "İş Yeri",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0,
                                fontFamily: "Brand-Regular",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Ride Details Container
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeIn,
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/taxi.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              const SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Car",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Brand-Bold",
                                    ),
                                  ),
                                  Text(
                                    (tripDirectionDetails.distanceText ==
                                                null ||
                                            tripDirectionDetails.durationText ==
                                                null)
                                        ? ""
                                        : tripDirectionDetails.durationText,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetails.distanceValue == null ||
                                        tripDirectionDetails.durationValue ==
                                            null)
                                    ? ""
                                    : "\TRY${AssistantMethods.calculateFares(tripDirectionDetails)}",
                                style: const TextStyle(
                                  fontFamily: "Brand-Bold",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 16.0),
                            Text("Cash"),
                            SizedBox(width: 6.0),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(17.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Request",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                FontAwesomeIcons.taxi,
                                color: Colors.white,
                                size: 26.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Request Ride Container
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeIn,
              child: Container(
                height: requestRideContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12.0,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 1.0,
                            color: Colors.black,
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Requesting a ride...',
                                speed: const Duration(milliseconds: 500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22.0),
                      GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.0),
                            border: Border.all(
                              width: 2.0,
                              color: Colors.grey[300]!,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 26.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        child: const Text(
                          "Cancel Ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initGeoFireListner() {
    Geofire.initialize("availabeDrivers");
    // comment
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)
        ?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvaiableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDirverFromList(map['key']);
            updateAvaiableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvaiableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvaiableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
    // comment
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: const Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        "assets/images/car_android.png",
      ).then((onValue) {
        nearByIcon = onValue;
        // Icon başarıyla yüklendiğinde burada kullanabiliriz
        // Örneğin:
        // setState(() {
        //   // Icon yüklendiğinde yapılacak işlemler
        // });
      }).catchError((error) {
        // Icon yüklenirken bir hata oluşursa, null yerine defaultMarker kullanabiliriz
        nearByIcon = BitmapDescriptor.defaultMarker;
      });
    }
  }

  void updateAvaiableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMakers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvaiablePosition = LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvaiablePosition,
        icon: nearByIcon ?? BitmapDescriptor.defaultMarker, // null check
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMakers.add(marker);
    }
    setState(() {
      markersSet = tMakers;
    });
  }
}
