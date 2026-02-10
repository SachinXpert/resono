import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({required this.title, required this.body, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const String _storageKey = 'notification_history';

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // Get Token
    final token = await _fcm.getToken();
    debugPrint("FCM Token: $token");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _saveNotification(message);
      }
    });
  }

  Future<void> _saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_storageKey) ?? [];
    
    final newNotif = NotificationModel(
      title: message.notification?.title ?? 'No Title', 
      body: message.notification?.body ?? '', 
      timestamp: DateTime.now()
    );

    history.insert(0, jsonEncode(newNotif.toJson())); // Add to top
    // Limit history if needed (e.g. 50 items)
    if (history.length > 50) {
      history.removeLast();
    }
    
    await prefs.setStringList(_storageKey, history);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_storageKey) ?? [];
    
    return history.map((e) => NotificationModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

// Top level handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  
  // Save to prefs in background
  try {
    final prefs = await SharedPreferences.getInstance();
    const String storageKey = 'notification_history';
    final List<String> history = prefs.getStringList(storageKey) ?? [];
    
    final newNotif = {
      'title': message.notification?.title ?? 'Start Ringo now!',
      'body': message.notification?.body ?? 'New notification',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    history.insert(0, jsonEncode(newNotif));
     if (history.length > 50) {
      history.removeLast();
    }
    await prefs.setStringList(storageKey, history);
  } catch (e) {
    debugPrint("Error saving background notification: $e");
  }
}
