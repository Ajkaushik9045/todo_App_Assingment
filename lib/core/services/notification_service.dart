import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';
import '../../features/todos/data/todo_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // FIXED: Declare the FirebaseMessaging field
  late final FirebaseMessaging _firebaseMessaging;
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  Timer? _notificationTimer;
  List<TodoModel> _todos = [];
  bool _isFirebaseInitialized = false;

  Future<void> initialize() async {
    print('🔔 NotificationService: Starting initialization...');
    
    if (!_isPlatformSupported()) {
      print('⚠️ NotificationService: Firebase not supported on this platform, using local notifications only');
      await _initializeLocalNotifications();
      return;
    }

    try {
      print('🔔 NotificationService: Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ NotificationService: Firebase initialized');

      // FIXED: Initialize the FirebaseMessaging instance
      _firebaseMessaging = FirebaseMessaging.instance;

      print('🔔 NotificationService: Requesting permissions...');
      await _requestPermissions();

      print('🔔 NotificationService: Initializing local notifications...');
      await _initializeLocalNotifications();

      print('🔔 NotificationService: Getting FCM token...');
      await _getFCMToken();

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      print('✅ NotificationService: Full initialization completed');
    } catch (e) {
      print('❌ NotificationService: Firebase initialization failed: $e');
      print('🔔 NotificationService: Falling back to local notifications only');
      await _initializeLocalNotifications();
    }
  }

  Future<void> initializeAsync() async {
    try {
      await initialize();
    } catch (e) {
      print('❌ NotificationService: Async initialization failed: $e');
    }
  }

  bool _isPlatformSupported() {
    if (Platform.isLinux) {
      return false;
    }
    return true;
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  Future<String?> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  void updateTodos(List<TodoModel> todos) {
    _todos = todos;
    _scheduleNotificationCheck();
  }

  void _scheduleNotificationCheck() {
    _notificationTimer?.cancel();
    
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndSendNotifications();
    });
    
    _checkAndSendNotifications();
  }

  void _checkAndSendNotifications() {
    final now = DateTime.now();
    
    for (final todo in _todos) {
      if (!todo.isCompleted) {
        final timeUntilDeadline = todo.deadline.difference(now);
        
        if (timeUntilDeadline.inMinutes >= 59 && timeUntilDeadline.inMinutes <= 61) {
          _sendLocalNotification(todo);
        }
      }
    }
  }

  Future<void> _sendLocalNotification(TodoModel todo) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'todo_reminders',
      'Todo Reminders',
      channelDescription: 'Notifications for upcoming todo deadlines',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      todo.id.hashCode,
      'Todo Reminder',
      '⏰ "${todo.title}" is due in 1 hour!',
      platformChannelSpecifics,
      payload: jsonEncode({
        'todoId': todo.id,
        'title': todo.title,
        'deadline': todo.deadline.toIso8601String(),
      }),
    );

    if (kDebugMode) {
      print('Notification sent for todo: ${todo.title}');
    }
  }

  void dispose() {
    _notificationTimer?.cancel();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

void _handleForegroundMessage(RemoteMessage message) {
  if (kDebugMode) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }
}
