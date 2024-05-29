import 'package:driver_app/AllScreens/mainscreen.dart';
import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CanInfoScreen extends StatelessWidget {
  CanInfoScreen({super.key});

  static const String idScreen = "carinfo";
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 22.0),
              Image.asset(
                "assets/images/logo.png",
                width: 390.0,
                height: 250.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12.0),
                    const Text(
                      "Araba Detaylarını Giriniz",
                      style: TextStyle(
                        fontFamily: "Brand-bold",
                        fontSize: 24.0,
                      ),
                    ),
                    const SizedBox(height: 26.0),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Araba Modeli",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15.0),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Araba Plakası",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15.0),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Araba Rengi",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15.0),
                    ),
                    const SizedBox(height: 42.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Butonun arka plan rengi mavi
                        ),
                        onPressed: () {
                          if (carModelTextEditingController.text.isEmpty) {
                            displayToasMessage(
                                "Lütfen Arabanızın Modelini Giriniz", context);
                          } else if (carNumberTextEditingController
                              .text.isEmpty) {
                            displayToasMessage(
                                "Lütfen Arabanızın Plakasını Giriniz.",
                                context);
                          } else if (carColorTextEditingController
                              .text.isEmpty) {
                            displayToasMessage(
                                "Lütfen Arabanızın Rengini Giriniz.", context);
                          } else {
                            saveDriverCarInfo(context);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Hesap Oluştur",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void displayToasMessage(String message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void saveDriverCarInfo(context) {
    String userId = currentfirebaseUser.uid;

    Map carInfoMap = {
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
    };

    driverRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
