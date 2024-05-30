import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/Models/rideDetails.dart';
import 'package:driver_app/Notifications/notificationDialog.dart';
import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messaging;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {
  final messaging.FirebaseMessaging _firebaseMessaging =
      messaging.FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // Request permission for notifications
    messaging.NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus ==
        messaging.AuthorizationStatus.authorized) {
      print('Permission granted');
    } else {
      print('Permission denied');
      return;
    }

    // Get device token
    String? token = await getFCMToken();
    print('Token: $token');

    // When a new notification arrives
    messaging.FirebaseMessaging.onMessage
        .listen((messaging.RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message), context);
    });

    // When a notification arrives while the app is open
    messaging.FirebaseMessaging.onMessageOpenedApp
        .listen((messaging.RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message), context);
    });

    // Subscribe to topics for drivers and users
    _firebaseMessaging.subscribeToTopic("alldrivers");
    _firebaseMessaging.subscribeToTopic("allusers");
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  String getRideRequestId(messaging.RemoteMessage message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      rideRequestId = message.data["ride_request_id"];
    } else {
      rideRequestId = message.data["ride_request_id"];
    }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    newRequestRef.child(rideRequestId).once().then((DatabaseEvent event) {
      DataSnapshot? dataSnapShot = event.snapshot;
      if (dataSnapShot != null && dataSnapShot.value != null) {
        // Add a null check for dataSnapShot before accessing its value property
        // Rest of your code remains unchanged
        assetsAudioPlayer.open(Audio("assets/sounds/alert.mp3"));
        assetsAudioPlayer.play();

        double pickUpLocationLat = double.parse(
            dataSnapShot.child('pickup/latitude').value.toString());
        double pickUpLocationLng = double.parse(
            dataSnapShot.child('pickup/longitude').value.toString());
        String pickUpAddress =
            dataSnapShot.child('pickup_address').value.toString();

        double dropOffLocationLat = double.parse(
            dataSnapShot.child('dropoff/latitude').value.toString());
        double dropOffLocationLng = double.parse(
            dataSnapShot.child('dropoff/longitude').value.toString());
        String dropOffAddress =
            dataSnapShot.child('dropoff_address').value.toString();

        String paymentMethod =
            dataSnapShot.child('payment_method').value.toString();
        String riderName = dataSnapShot.child('rider_name').value.toString();
        String riderPhone = dataSnapShot.child('rider_phone').value.toString();

        RideDetails rideDetails = RideDetails(
          pickup_address: pickUpAddress,
          dropoff_address: dropOffAddress,
          pickup: LatLng(pickUpLocationLat, pickUpLocationLng),
          dropoff: LatLng(dropOffLocationLat, dropOffLocationLng),
          ride_request_id: rideRequestId,
          payment_method: paymentMethod,
          rider_name: riderName,
          rider_phone: riderPhone,
        );

        print("Information ::");
        print(rideDetails.pickup_address);
        print(rideDetails.dropoff_address);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              NotificationDialog(rideDetails: rideDetails),
        );
      }
    }).catchError((error) {
      print("Error retrieving ride request info: $error");
    });
  }
}
