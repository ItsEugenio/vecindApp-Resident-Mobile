import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/MyFirebaseMessagingService.dart';
import 'home/presentation/pages/admin_page.dart';
import 'login/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  final bool isAuthenticated;

  const SplashScreen({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final MyFirebaseMessagingService _firebaseMessagingService = MyFirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    await _firebaseMessagingService.initNotifications();

    // ✅ Redirigir según autenticación
    if (widget.isAuthenticated) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 🔄 Pantalla de carga mientras inicializa FCM
      ),
    );
  }
}
