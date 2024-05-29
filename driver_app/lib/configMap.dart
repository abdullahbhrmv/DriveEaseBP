import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/Models/allUsers.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = "AIzaSyAyzWq7pxTPgpPoZ_Q-ckQHnRGJuVDwZjc";

late User firebaseUser;
late Users userCurrentInfo;
late User currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription = null;
