import 'package:driver_app/AllScreens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Sürücü Adı",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Email: driver@example.com",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Bilgiler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Telefon"),
              subtitle: Text("+90 555 555 55 55"),
            ),
            const ListTile(
              leading: Icon(Icons.car_rental),
              title: Text("Araç"),
              subtitle: Text("Model: Toyota Prius\nPlaka: 34 AB 1234"),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                child: const Text("Çıkış Yap"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Çıkış Yap"),
          content: const Text("Çıkmak istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Çıkış Yap"),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, LoginScreen.idScreen);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
