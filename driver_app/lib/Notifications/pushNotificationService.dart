import 'dart:io';

import 'package:driver_app/Models/rideDetails.dart';
import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Bildirim izni iste
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission granted');
    } else {
      print('Permission denied');
      return;
    }

    // Cihaz token'ını al
    String? token = await _getFCMToken();

    print('Token: $token');

    // Yeni bir bildirim geldiğinde
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message));
    });

    // Uygulama açıkken bildirim geldiğinde
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message));
    });

    // Alıcıların ve kullanıcıların bildirimlerini dinlemek için abone ol
    _firebaseMessaging.subscribeToTopic("alldrivers");
    _firebaseMessaging.subscribeToTopic("allusers");
  }

  Future<String?> _getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  String getRideRequestId(RemoteMessage message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      rideRequestId = message.data["ride_request_id"];
    } else {
      rideRequestId = message.data["ride_request_id"];
    }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId) {
    newRequestRef.child(rideRequestId).once().then((DatabaseEvent event) {
      DataSnapshot dataSnapShot = event.snapshot;
      if (dataSnapShot.value != null) {
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
      }
    });
  }
}
