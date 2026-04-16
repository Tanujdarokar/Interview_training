import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.checkPermissions();
  await initializeService();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false, // Run in background without a persistent notification
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  // Initialize notifications for the background isolate
  await NotificationService().init();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Background logic: Check reminders every 30 seconds for better accuracy
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force reload to get latest changes from UI isolate
      
      final jsonStr = prefs.getString('user_reminders');
      
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          final List decoded = jsonStr != null ? jsonDecode(jsonStr) : [];
          final pending = decoded.length;
          
          service.setForegroundNotificationInfo(
            title: "Pro Reminder Active",
            content: pending > 0 
              ? "Monitoring $pending active reminders" 
              : "Background monitor active",
          );
        }
      }

      if (jsonStr == null || jsonStr == '[]') return;
      
      final List decoded = jsonDecode(jsonStr);
      final now = DateTime.now();
      bool updated = false;

      for (var i = decoded.length - 1; i >= 0; i--) {
        var item = decoded[i];
        try {
          final dateTime = DateTime.parse(item['dateTime']);
          
          // Trigger if time is now or was in the last 60 seconds
          if (dateTime.isBefore(now) && dateTime.isAfter(now.subtract(const Duration(seconds: 60)))) {
            final String stringId = item['id'].toString();
            final start = stringId.length > 9 ? stringId.length - 9 : 0;
            final int id = int.tryParse(stringId.substring(start)) ?? -1;
            
            // Show notification immediately from background
            await NotificationService().showNotification(
              id: id,
              title: "Reminder: ${item['label']}",
              body: "Your scheduled task is due!",
            );
            
            decoded.removeAt(i);
            updated = true;
          } else if (dateTime.isBefore(now.subtract(const Duration(minutes: 10)))) {
            // Cleanup very old reminders
            decoded.removeAt(i);
            updated = true;
          }
        } catch (e) {
          debugPrint("Error processing reminder: $e");
        }
      }

      if (updated) {
        await prefs.setString('user_reminders', jsonEncode(decoded));
        service.invoke('update', {"reminders_updated": true});
      }
    } catch (e) {
      debugPrint("Background loop error: $e");
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Interview Pro',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
