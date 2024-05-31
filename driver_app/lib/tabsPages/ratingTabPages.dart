import 'package:flutter/material.dart';

class RatingTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.blue,
        backgroundColor: Colors.blue,
        title: const Text(
          "Değerlendirmeler",
         style: TextStyle(
            fontFamily: "Brand-Regular",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Yolculuk Değerlendirmeleri",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "Brand-Regular",),
            ),
            const SizedBox(height: 16),
            // Değerlendirmelerin listesi
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Örnek veri sayısı
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Yolculuk $index"),
                  subtitle: Text("Puan: ${index + 1} / 5"),
                  leading: const Icon(Icons.star),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Ortalama Puan: 4.0", // Örnek ortalama puan
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Brand-Regular",),
            ),
          ],
        ),
      ),
    );
  }
}
