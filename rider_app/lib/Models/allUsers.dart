import 'package:firebase_database/firebase_database.dart';

class Users {
  late String id;
  late String email;
  late String name;
  late String phone;

  Users({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
  });

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key ?? '';
    final data = dataSnapshot.value as Map<dynamic, dynamic>? ?? {};
    email = data["email"] ?? '';
    name = data["name"] ?? '';
    phone = data["phone"] ?? '';
  }
}
