// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:driver_app/AllScreens/registrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/AllScreens/mainscreen.dart';
import 'package:driver_app/AllWidgets/progressDialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String idScreen = "login";

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      // ProgressDialog'u göster
      showDialog(
        context: context,
        barrierDismissible:
            false, // Kullanıcı arkaplandaki boşluğa tıklayarak dialog'u kapatamaz
        builder: (BuildContext context) {
          return const ProgressDialog(message: 'Giriş yapılıyor...');
        },
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ProgressDialog'u kapat
      Navigator.pop(context);

      // Kullanıcı girişi başarılıysa ana ekranı aç
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // ProgressDialog'u kapat
      Navigator.pop(context);

      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // Kullanıcı bulunamadı veya şifre yanlış
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text('Geçersiz e-posta veya şifre.'),
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
        // Diğer auth hatalarını ele almak için gerekli kodu buraya ekleyin.
        print('Error while signing in: ${e.code}');
      }
    } catch (e) {
      // Firebase Authentication dışındaki hataları ele almak için gerekli kodu buraya ekleyin.
      print('Error while signing in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 35,
              ),
              const Image(
                image: AssetImage("assets/images/logo.png"),
                width: 400,
                height: 250,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Sürücü olarak oturum açın",
                style: TextStyle(fontFamily: "Brand Bold", fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Şifre",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      ),
                      onPressed: () {
                        signIn(
                          context,
                          emailController.text,
                          passwordController.text,
                        );
                      },
                      child: const Text(
                        'Giriş Yap',
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
                      builder: (context) => RegistrationScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu? ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Kayıt ol',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
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
