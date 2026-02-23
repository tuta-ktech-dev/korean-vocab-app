import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service quản lý Local Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Khởi tạo notification service
  Future<void> init() async {
    if (_initialized) return;

    // Khởi tạo timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: initSettings);

    _initialized = true;
  }

  /// SRS Reminder - Nhắc từ đến hạn
  Future<void> scheduleSRSReminder({
    required int dueCount,
    required String firstWord,
    required DateTime scheduledTime,
  }) async {
    await _createNotificationChannel();

    // Xóa notification cũ
    await _notifications.cancel(id: 1);

    if (dueCount == 0) return;

    await _notifications.zonedSchedule(
      id: 1,
      title: '$dueCount từ cần ôn tập',
      body: firstWord,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'korean_vocab_channel',
          'Korean Vocab Notifications',
          channelDescription: 'Thông báo nhắc nhở học từ vựng',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode({'type': 'srs', 'count': dueCount}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Random Word - Từ ngẫu nhiên
  Future<void> scheduleRandomWord({
    required String word,
    required String? pronunciation,
    required String meaning,
    required DateTime scheduledTime,
    required int id,
  }) async {
    await _createNotificationChannel();

    final title = word;
    final body = pronunciation != null ? '[$pronunciation]\n$meaning' : meaning;

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'korean_vocab_channel',
          'Korean Vocab Notifications',
          channelDescription: 'Thông báo nhắc nhở học từ vựng',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: json.encode({'type': 'random', 'word': word}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Tạo Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'korean_vocab_channel',
      'Korean Vocab Notifications',
      description: 'Thông báo nhắc nhở học từ vựng',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Cancel tất cả notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Check permission
  Future<bool> requestPermission() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return result ?? true;
  }
}
