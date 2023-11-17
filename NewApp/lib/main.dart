import 'package:best_todo_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('ic_notification');

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('Notification initialization successful');
  } catch (e) {
    print('Notification initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building MyApp widget');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Title',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

Future<void> _requestNotificationPermissions() async {
  // Check if notification permissions are granted
  var status = await Permission.notification.status;

  if (!status.isGranted) {
    // If permissions are not granted, request permission
    await Permission.notification.request();
    // Check the status again after requesting permission
    status = await Permission.notification.status;
  }

  // Print the final status for debugging
  print('Notification permission status: $status');
}
