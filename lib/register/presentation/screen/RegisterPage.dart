import 'package:flutter/material.dart';
import 'package:vecindapp_residente/login/presentation/pages/login_page.dart';
import '../widgets/button.dart';

class Registerpage extends StatelessWidget {
  const Registerpage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Register Page"),
        
      ),
    body: Center(
      child: Column(
        children: [
          Text("Ingresa tus datos para registrar"),
          Button(
                  text: "Login",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
        ],
      ),
    ),
    );
  }
}