import 'package:flutter/material.dart';
import 'package:polar_hr_monitor_analysis/presentation/device_dashboard/device_dashboard.dart';
import 'package:polar_hr_monitor_analysis/presentation/device_pairing_screen/device_pairing_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Polar HR Monitor',
          theme: ThemeData(primarySwatch: Colors.blue),

          // ✅ กำหนดหน้าแรก
          home: const DeviceDashboard(),

          // ✅ กำหนด route mapping
          routes: {
            '/device_pairing': (context) => const DevicePairingScreen(),
          },
        );
      },
    );
  }
}
