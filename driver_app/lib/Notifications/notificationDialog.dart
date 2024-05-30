import 'dart:async';

import 'package:driver_app/AllScreens/newRideScreen.dart';
import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:driver_app/Models/rideDetails.dart';
import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;

  const NotificationDialog({Key? key, required this.rideDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30.0),
            Image.asset(
              "assets/images/taxi.png",
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            const Text(
              "Yeni Yolculuk Talebi Mevcut",
              style: TextStyle(
                fontFamily: "Brand-Bold",
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/pickion.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Text(
                          rideDetails.pickup_address,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/desticon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Text(
                          rideDetails.dropoff_address,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Divider(
              height: 2.0,
              color: Colors.black,
              thickness: 2.0,
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.red),
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                    ),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.of(context).pop(); // Diyalog kutusunu kapat
                    },
                    child: Text(
                      "İptal Etmek".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRide(context);
                    },
                    child: Text(
                      "Kabul etmek".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(BuildContext context) {
    rideRequestRef.once().then((DataSnapshot dataSnapShot) {
          Navigator.pop(context);
          String theRideId = "";
          if (dataSnapShot.value != null) {
            theRideId = dataSnapShot.value.toString();
          } else {
            displayToastMessage("Yolculuk mevcut değil.", context);
          }

          if (theRideId == rideDetails.ride_request_id) {
            rideRequestRef.set("accepted");
            AssistantMethods.disableHomeTabLiveLocationUpdates();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewRideScreen(rideDetails: rideDetails)));
          } else if (theRideId == "cancelled") {
            displayToastMessage("Yolculuk iptal edildi.", context);
          } else if (theRideId == "timeout") {
            displayToastMessage("Sürüşünüz zaman aşımına uğradı.", context);
          } else {
            displayToastMessage("Yolculuk mevcut değil.", context);
          }
        } as FutureOr Function(DatabaseEvent value));
  }

  void displayToastMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
