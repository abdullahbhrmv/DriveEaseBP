import 'dart:async';
import 'package:driver_app/AllWidgets/CollectFareDialog.dart';
import 'package:driver_app/AllWidgets/progressDialog.dart';
import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/Assistants/mapKitAssistant.dart';
import 'package:driver_app/Models/rideDetails.dart';
import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({Key? key, required this.rideDetails}) : super(key: key);

  final RideDetails rideDetails;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.015137, 28.979530), // Coordinates for Istanbul
    zoom: 14.4746,
  );

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newRideGoogleMapController;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  Set<Polyline> polyLineSet = {};
  List<LatLng> polylineCorOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  late LocationSettings locationSettings;
  late BitmapDescriptor animatingMarkerIcon;
  late Position myPosition;
  String status = "accepted";
  late String durationRide = "";
  bool isRequestingDirection = false;
  String btntitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  late Timer timer;
  late int durationCounter = 0;

  @override
  void initState() {
    super.initState();
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    acceptRideRequest();
  }

  void createIconMarker() async {
    if (animatingMarkerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      final BitmapDescriptor bitmapDescriptor =
          await BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        "assets/images/car_android.png",
      ).catchError((error) {
        animatingMarkerIcon = BitmapDescriptor.defaultMarker;
      });
      setState(() {
        animatingMarkerIcon = bitmapDescriptor;
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos =
        const LatLng(0.0, 0.0); // Değerlerin double türünde olması sağlandı

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      var rot = MapKitassistant.getMarkerRotation(
        oldPos.latitude,
        oldPos.longitude,
        myPosition.latitude,
        myPosition.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("animating"),
        position: mPosition,
        icon: animatingMarkerIcon,
        rotation: rot.toDouble(), // Rotasyonun double türünde olması sağlandı
        infoWindow: const InfoWindow(title: "Mevcut konum"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.removeWhere((marker) => marker.markerId.value == "animating");
        markerSet.add(animatingMarker);
      });

      oldPos = mPosition;
      updateRideDetails();

      String rideRequestId = widget.rideDetails.ride_request_id;
      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
      };
      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markerSet,
            circles: circleSet,
            polylines: polyLineSet,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265.0;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng = widget.rideDetails.pickup;

              await getPlaceDirection(currentLatLng, pickUpLatLng);

              getRideLiveLocationUpdates();
            },
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              height: 270.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  children: [
                    const Text(
                      "10 dk",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Brand-Bold",
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.rideDetails.rider_name,
                          style: const TextStyle(
                            fontFamily: "Brand-Bold",
                            fontSize: 24.0,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.phone_android),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26.0),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(width: 18.0),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.pickup_address,
                              style: const TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(width: 18.0),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.dropoff_address,
                              style: const TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Your button onPressed logic...
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Arrived",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.directions_car,
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Lütfen bekleyin...",
      ),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(details!.encodedPoints);

    polylineCorOrdinates.clear();

    if (decodedPolylinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResult) {
        polylineCorOrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: Colors.pink,
        jointType: JointType.round,
        points: polylineCorOrdinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
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

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: const MarkerId("dropOffId"),
    );

    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
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
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation!.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation!.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation!.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        '${driversInformation!.car_color} - ${driversInformation!.car_model}');

    driverRef
        .child(currentfirebaseUser.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      if (myPosition == null) {
        return;
      }

      var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickup;
      } else {
        destinationLatLng = widget.rideDetails.dropoff;
      }

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async {
    timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Lütfen bekleyin...",
      ),
    );

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
        widget.rideDetails.pickup, currentLatLng);
    Navigator.pop(context);
    int fareAmount = AssistantMethods.calculateFares(directionDetails!);

    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef
        .child(rideRequestId)
        .child("fares")
        .set(fareAmount.toString());
    newRequestRef.child(rideRequestId).child("status").set("enden");
    rideStreamSubscription!.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectFareDialog(
        paymentMethod: widget.rideDetails.payment_method,
        fareAmount: fareAmount,
      ),
    );

    saveEarnings(fareAmount);
  }

  void saveEarnings(int fareAmount) {
    driverRef
        .child(currentfirebaseUser.uid)
        .child("earnings")
        .once()
        .then((DataSnapshot dataSnapShot) {
          if (dataSnapShot.value != null) {
            double oldEarnings = double.parse(dataSnapShot.value.toString());
            double totalEarnings = fareAmount + oldEarnings;

            driverRef
                .child(currentfirebaseUser.uid)
                .child("earnings")
                .set(totalEarnings.toStringAsFixed(2));
          } else {
            double totalEarnings = fareAmount.toDouble();
            driverRef
                .child(currentfirebaseUser.uid)
                .child("earnings")
                .set(totalEarnings.toStringAsFixed(2));
          }
        } as FutureOr Function(DatabaseEvent value));
  }
}
