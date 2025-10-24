import 'package:flutter/material.dart';
import '../presentation/permission_request_screen/permission_request_screen.dart';
import '../presentation/device_dashboard/device_dashboard.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/device_pairing_screen/device_pairing_screen.dart';
import '../presentation/device_management_screen/device_management_screen.dart';
import '../presentation/wireless_display_screen/wireless_display_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String permissionRequest = '/permission-request-screen';
  static const String deviceDashboard = '/device-dashboard';
  static const String splash = '/splash-screen';
  static const String devicePairing = '/device-pairing-screen';
  static const String deviceManagement = '/device-management-screen';
  static const String wirelessDisplay = '/wireless-display-screen';
  static const String settingsScreen = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    permissionRequest: (context) => const PermissionRequestScreen(),
    deviceDashboard: (context) => const DeviceDashboard(),
    splash: (context) => const SplashScreen(),
    devicePairing: (context) => const DevicePairingScreen(),
    deviceManagement: (context) => const DeviceManagementScreen(),
//    wirelessDisplay: (context) => const WirelessDisplayScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    // TODO: Add your other routes here
  };
}
