import 'package:driver_app/Assistants/assistantMethods.dart';
import 'package:flutter/material.dart';

class CollectFareDialog extends StatelessWidget {
  const CollectFareDialog(
      {super.key, required this.paymentMethod, required this.fareAmount});
  final String paymentMethod;
  final int fareAmount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
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
            const SizedBox(height: 22.0),
            const Text("Yolculuk Ücreti"),
            const SizedBox(height: 22.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text(
              "\TRY$fareAmount",
              style: const TextStyle(
                fontSize: 55.0,
                fontFamily: "Brand-Bold",
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Text(
                "Bu toplam yolculuk tutarıdır, biniciye göre değişmiştir.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  AssistantMethods.enableHomeTabLiveLocationUpdates();
                },
                child: const Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nakit Toplam",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 26.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
