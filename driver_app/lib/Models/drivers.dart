import 'package:firebase_database/firebase_database.dart';

class Drivers {
  late String name;
  late String phone;
  late String email;
  late String id;
  late String car_color;
  late String car_model;
  late String car_number;

  Drivers({
    required this.name,
    required this.phone,
    required this.email,
    required this.id,
    required this.car_color,
    required this.car_model,
    required this.car_number,
  });

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key ?? 'Unknown ID';
    var data = dataSnapshot.value as Map?;
    
    if (data != null) {
      phone = data["phone"] ?? 'Unknown Phone';
      email = data["email"] ?? 'Unknown Email';
      name = data["name"] ?? 'Unknown Name';
      
      var carDetails = data["car_details"] as Map?;
      if (carDetails != null) {
        car_color = carDetails["car_color"] ?? 'Unknown Color';
        car_model = carDetails["car_model"] ?? 'Unknown Model';
        car_number = carDetails["car_number"] ?? 'Unknown Number';
      } else {
        car_color = 'Unknown Color';
        car_model = 'Unknown Model';
        car_number = 'Unknown Number';
      }
    } else {
      phone = 'Unknown Phone';
      email = 'Unknown Email';
      name = 'Unknown Name';
      car_color = 'Unknown Color';
      car_model = 'Unknown Model';
      car_number = 'Unknown Number';
    }
  }
}
