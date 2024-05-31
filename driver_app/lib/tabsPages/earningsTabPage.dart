import 'package:flutter/material.dart';

class EarningsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kazanç",
          style: TextStyle(
            fontFamily: "Brand-Regular",
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bu Ayki Kazançlar",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Brand-Regular",
              ),
            ),
            const SizedBox(height: 16),
            // Kazançların listesi
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Örnek veri sayısı
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Yolculuk $index"),
                  subtitle: Text("Kazanç: ₺${index * 20}.00"),
                  leading: const Icon(Icons.attach_money),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Toplam Kazanç: ₺100.00", // Örnek toplam kazanç
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
