import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../core/storage/storage.dart'; // ✅ Asegúrate de importar Storage para obtener el token JWT

class MyFirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://vecindappback-production.up.railway.app"));
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// ✅ Inicializar notificaciones FCM
  Future<void> initNotifications() async {
    print("🔄 [FCMS] Iniciando configuración de notificaciones...");

    // 🔹 Pedir permisos en iOS (Android no lo necesita)
    if (Platform.isIOS) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print("❌ [FCMS] Permiso denegado para recibir notificaciones.");
        return;
      }
    }

    print("✅ [FCMS] Permiso concedido para recibir notificaciones.");

    // 🔹 Obtener el token de FCM
    String? token = await _firebaseMessaging.getToken();
    print("📲 [FCMS] Token obtenido: $token");

    if (token != null) {
      await _saveToken(token);
      await _sendTokenToServer(token);
    }

    // 📌 **Escuchar notificaciones en diferentes estados de la app**
    _configureLocalNotifications();
    _configureForegroundNotifications();
    _configureBackgroundNotifications();
  }

  /// ✅ Configurar Notificaciones Locales
  void _configureLocalNotifications() {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    _localNotifications.initialize(initSettings);
  }

  /// ✅ Mostrar Notificación en Primer Plano
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0, // ID de la notificación
      message.notification?.title ?? "Sin título",
      message.notification?.body ?? "Sin contenido",
      notificationDetails,
    );
  }

  /// ✅ Guardar el token en SharedPreferences para evitar llamadas innecesarias
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
    print("💾 [FCMS] Token guardado en SharedPreferences.");
  }

  /// ✅ Enviar el token FCM al backend con el token JWT
  Future<void> _sendTokenToServer(String token) async {
    try {
      String? jwtToken = await Storage.getToken();

      if (jwtToken == null) {
        print("⚠️ [FCMS] No hay un token JWT disponible. No se enviará el token FCM.");
        return;
      }

      final response = await _dio.post(
        "/auth/fcm-token",
        data: {"fcmToken": token},
        options: Options(headers: {
          "accept": "*/*",
          "Authorization": "Bearer $jwtToken",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ [FCMS] Token FCM enviado correctamente al backend.");
      } else {
        print("❌ [FCMS] Error al enviar token: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("❌ [FCMS] Excepción al enviar token: $e");
    }
  }

  /// ✅ Configurar manejo de notificaciones cuando la app está en primer plano
  void _configureForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 [FCMS] Notificación recibida en PRIMER PLANO:");
      print("   🔹 Título: ${message.notification?.title}");
      print("   🔹 Cuerpo: ${message.notification?.body}");
      print("   🔹 Datos: ${message.data}");

      // **Mostrar la notificación localmente**
      _showNotification(message);
    });
  }

  /// ✅ Configurar notificaciones en segundo plano y cuando la app está cerrada
  void _configureBackgroundNotifications() {
    // 🔹 Cuando la notificación es tocada y la app está cerrada
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("📩 [FCMS] Notificación recibida cuando la app estaba CERRADA:");
        print("   🔹 Título: ${message.notification?.title}");
        print("   🔹 Cuerpo: ${message.notification?.body}");
        print("   🔹 Datos: ${message.data}");
      }
    });

    // 🔹 Cuando la notificación es tocada y la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 [FCMS] Notificación recibida en SEGUNDO PLANO:");
      print("   🔹 Título: ${message.notification?.title}");
      print("   🔹 Cuerpo: ${message.notification?.body}");
      print("   🔹 Datos: ${message.data}");
    });
  }
}
