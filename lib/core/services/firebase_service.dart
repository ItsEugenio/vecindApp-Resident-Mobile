import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../storage/storage.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio dio = Dio(BaseOptions(baseUrl: "https://vecindappback-production.up.railway.app"));

  Future<void> initializeFCM() async {
    // Solicitar permisos para recibir notificaciones en Android (Opcional)
    await _firebaseMessaging.requestPermission();

    // Obtener el FCM Token
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      await _saveTokenLocally(fcmToken);
      await _sendTokenToServer(fcmToken);
    }

    // Manejo de notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 [FCMS] Notificación recibida en primer plano: ${message.notification?.title}");
    });

    // Manejo de notificaciones cuando la app está en segundo plano o cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 [FCMS] Notificación abierta: ${message.notification?.title}");
    });
  }

  Future<void> _saveTokenLocally(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print("✅ [FCMS] Token guardado localmente: $token");
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    final String? jwtToken = await Storage.getToken(); // Obtener JWT
    if (jwtToken == null) {
      print("⚠️ [FCMS] No hay JWT, no se enviará el token a la API.");
      return;
    }

    try {
      final response = await dio.post(
        "/auth/fcm-token",
        data: {"fcmToken": fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode == 200) {
        print("✅ [FCMS] Token enviado exitosamente a la API.");
      } else {
        print("❌ [FCMS] Error al enviar token: Código ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [FCMS] Excepción al enviar token: $e");
    }
  }
}
