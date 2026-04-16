import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // To access navigatorKey

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final int? id = notificationResponse.id;
  if (id == null) return;

  if (notificationResponse.actionId == 'stop_vibration') {
    FlutterLocalNotificationsPlugin().cancel(id);
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_reminders') ?? '[]';
    List decoded = jsonDecode(jsonStr);
    decoded.removeWhere((item) {
      final String stringId = item['id'].toString();
      final start = stringId.length > 9 ? stringId.length - 9 : 0;
      final int derivedId = int.tryParse(stringId.substring(start)) ?? -1;
      return derivedId == id;
    });
    await prefs.setString('user_reminders', jsonEncode(decoded));
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    String zoneId = timeZoneName.toString();

    if (zoneId.contains('(') && zoneId.contains(')')) {
      final match = RegExp(r'\(([^,]+)').firstMatch(zoneId);
      if (match != null) {
        zoneId = match.group(1)!.trim();
      }
    }

    try {
      tz.setLocalLocation(tz.getLocation(zoneId));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Foreground handling: Show in-app dialog
        _showInAppReminderDialog(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(const AndroidNotificationChannel(
        'urgent_reminders_channel_v7',
        'Urgent Reminders',
        description: 'Critical reminders with sound and vibration',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.indigo,
        showBadge: true,
      ));
    }
  }

  void _showInAppReminderDialog(NotificationResponse response) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final payload = response.payload ?? "Reminder|Your task is due!";
    final parts = payload.split('|');
    final title = parts[0];
    final body = parts.length > 1 ? parts[1] : "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.alarm, color: Colors.indigo),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () async {
              // Snooze for 5 minutes
              Navigator.pop(context);
              await scheduleNotification(
                id: response.id ?? 0,
                title: title,
                body: body,
                scheduledDate: DateTime.now().add(const Duration(minutes: 5)),
              );
            },
            child: const Text("Snooze (5m)"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Stop & Remove
              Navigator.pop(context);
              await _notificationsPlugin.cancel(response.id ?? 0);
              
              final prefs = await SharedPreferences.getInstance();
              final jsonStr = prefs.getString('user_reminders') ?? '[]';
              List decoded = jsonDecode(jsonStr);
              decoded.removeWhere((item) {
                final String stringId = item['id'].toString();
                final start = stringId.length > 9 ? stringId.length - 9 : 0;
                final int derivedId = int.tryParse(stringId.substring(start)) ?? -1;
                return derivedId == (response.id ?? 0);
              });
              await prefs.setString('user_reminders', jsonEncode(decoded));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text("Stop"),
          ),
        ],
      ),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_reminders_channel_v7',
          'Urgent Reminders',
          channelDescription: 'Critical reminders with sound and vibration',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.indigo,
          ledOnMs: 1000,
          ledOffMs: 500,
          vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
          additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT = 4
          styleInformation: BigTextStyleInformation(body),
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'stop_vibration',
              'Stop',
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              'Snooze',
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '$title|$body',
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_reminders_channel_v7',
          'Urgent Reminders',
          channelDescription: 'Critical reminders with sound and vibration',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.indigo,
          ledOnMs: 1000,
          ledOffMs: 500,
          vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
          additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT
          styleInformation: BigTextStyleInformation(body),
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction('stop_vibration', 'Stop', cancelNotification: true),
            const AndroidNotificationAction('snooze', 'Snooze', cancelNotification: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: payload ?? '$title|$body',
    );
  }

  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.requestNotificationsPermission();
      await plugin?.requestExactAlarmsPermission();
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
