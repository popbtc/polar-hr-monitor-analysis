import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart' as loc;

/// 🔐 รวมทุกฟังก์ชันสำหรับขอและตรวจสอบ Permission ของแอป พร้อม Snackbar เตือน
class Permissions {
  // 🔹 ตรวจสอบว่ามีสิทธิ์ครบทั้งหมดหรือยัง
  static Future<bool> checkAll() async {
    try {
      final bluetoothGranted = await _checkBluetoothPermissions();
      final locationGranted = await Permission.locationWhenInUse.isGranted;
      final notificationGranted = await Permission.notification.isGranted;

      return bluetoothGranted && locationGranted && notificationGranted;
    } catch (e) {
      debugPrint("checkAll() error: $e");
      return false;
    }
  }

  // 🔹 ขอสิทธิ์ทั้งหมดพร้อมกัน
  static Future<void> requestAll(BuildContext context) async {
    try {
      await requestBluetooth();
      await requestLocation(context);
      await requestNotification();
    } catch (e) {
      debugPrint("requestAll() error: $e");
    }
  }

  // 🔹 ตรวจสอบ Bluetooth (รองรับ Android 12+)
  static Future<bool> _checkBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.status;
      final connect = await Permission.bluetoothConnect.status;
      return scan.isGranted && connect.isGranted;
    } else {
      final status = await Permission.bluetooth.status;
      return status.isGranted;
    }
  }

  // 🔹 ขอ Bluetooth permission (Nearby Devices)
  static Future<bool> requestBluetooth() async {
    try {
      if (Platform.isAndroid) {
        final scan = await Permission.bluetoothScan.request();
        final connect = await Permission.bluetoothConnect.request();
        return scan.isGranted && connect.isGranted;
      } else {
        final status = await Permission.bluetooth.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint("requestBluetooth() error: $e");
      return false;
    }
  }

  // 🔹 ขอ Location permission (จำเป็นสำหรับ BLE scan)
  static Future<bool> requestLocation(BuildContext context) async {
    try {
      // 1️⃣ ขอสิทธิ์ Location ก่อน
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        _showSnackBar(
          context,
          message: "⚠️ Location permission required",
          actionLabel: "Open Settings",
          onPressed: openAppSettings,
        );
        return false;
      }

      // 2️⃣ ตรวจสอบว่าเปิด Location Service หรือยัง
      final location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showSnackBar(
            context,
            message: "⚠️ Please enable Location Service",
            actionLabel: "Open Settings",
            onPressed: openAppSettings,
          );
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint("requestLocation() error: $e");
      return false;
    }
  }

  // 🔹 ขอ Notification permission
  static Future<bool> requestNotification() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint("requestNotification() error: $e");
      return false;
    }
  }

  // 🔹 เปิด Settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  // 🔹 แสดง Snackbar เตือนพร้อมปุ่ม “Open Settings”
  static void _showSnackBar(
      BuildContext context, {
        required String message,
        required String actionLabel,
        required VoidCallback onPressed,
      }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onPressed,
          textColor: Colors.white,
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
