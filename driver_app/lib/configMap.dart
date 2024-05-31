import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/Models/drivers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/Models/allUsers.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = "Your_Google_API_KEY";

late User firebaseUser;
late Users userCurrentInfo;
late User currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription;

StreamSubscription<Position>? rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();
late Position currentPosition;

Drivers? driversInformation; // Make the variable nullable

// Example usage
void exampleFunction() {
  if (driversInformation != null) {
    print(driversInformation!.name);
  } else {
    print('Drivers information is not initialized yet.');
  }
}
