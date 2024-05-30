import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver_app/AllScreens/loginScreen.dart';
import 'package:driver_app/AllWidgets/progressDialog.dart';
import 'package:driver_app/AllScreens/canInfoScreen.dart';
import 'package:driver_app/configMap.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({Key? key});

  static const String idScreen = "register";

  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController phoneTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final TextEditingController confirmPasswordTextEditingController =
      TextEditingController();

  Future<void> signUp(
      BuildContext context, String email, String password) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialog(message: 'Hesap oluşturuluyor...');
        },
      );

      if (!email.contains('@')) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text('Geçerli bir e-posta adresi giriniz.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (password.length < 8) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text('Şifre en az 8 karakter olmalıdır.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (password != confirmPasswordTextEditingController.text) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text('Şifreler eşleşmiyor.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await addUserToRealtimeDB(user);
        currentfirebaseUser = user; // Assigning the firebaseUser here
      }

      Navigator.of(context).pop(); // Close the progress dialog
      Navigator.pushNamed(context, CanInfoScreen.idScreen);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close the progress dialog

      if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text(
                  'Bu e-posta adresi zaten bir hesapta kullanılıyor.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      } else {
        print('Error while signing up: ${e.code}');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the progress dialog
      print('Error while signing up: $e');
    }
  }

  Future<void> addUserToRealtimeDB(User user) async {
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(user.uid); // Update the reference to 'drivers'
    await driverRef.set({
      'name': nameTextEditingController.text,
      'email': emailTextEditingController.text,
      'phone': phoneTextEditingController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 35),
              const Image(
                image: AssetImage("assets/images/logo.png"),
                width: 400,
                height: 250,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Sürücü | Kayıt Ol",
                style: TextStyle(fontFamily: "Brand Bold", fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "İsim, Soyisim",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    IntlPhoneField(
                      controller: phoneTextEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      initialCountryCode: 'TR',
                      onChanged: (phone) {
                        print(phone.completeNumber);
                      },
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Şifre",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordTextEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Şifreyi Onayla",
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains('@')) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Hata'),
                                content: const Text(
                                    'Geçerli bir e-posta adresi giriniz.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (passwordTextEditingController.text.length <
                            8) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Hata'),
                                content: const Text(
                                    'Şifre en az 8 karakter olmalıdır.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (passwordTextEditingController.text !=
                            confirmPasswordTextEditingController.text) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Hata'),
                                content: const Text('Şifreler eşleşmiyor.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          signUp(
                            context,
                            emailTextEditingController.text,
                            passwordTextEditingController.text,
                          );
                        }
                      },
                      child: const Text(
                        'Sonraki',
                        style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız var mı? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Giriş Yap',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
