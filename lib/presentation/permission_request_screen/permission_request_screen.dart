import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_bluetooth_icon_widget.dart';
import './widgets/expandable_info_widget.dart';
import './widgets/permission_card_widget.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({Key? key}) : super(key: key);

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _isBluetoothGranted = false;
  bool _isLocationGranted = false;
  bool _isNotificationGranted = false;
  bool _isCheckingPermissions = false;
  bool _isRequestingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  // 🔹 ตรวจสอบ permission ปัจจุบัน
  Future<void> _checkCurrentPermissions() async {
    setState(() => _isCheckingPermissions = true);

    try {
      final bluetoothStatus = await _checkBluetoothPermissions();
      final locationStatus = await Permission.locationWhenInUse.status;
      final notificationStatus = await Permission.notification.status;

      setState(() {
        _isBluetoothGranted = bluetoothStatus;
        _isLocationGranted = locationStatus.isGranted;
        _isNotificationGranted = notificationStatus.isGranted;
        _isCheckingPermissions = false;
      });

      // ถ้าครบทุกสิทธิ์ → ไป dashboard
      if (_isBluetoothGranted && _isLocationGranted && _isNotificationGranted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/device-dashboard');
        }
      }
    } catch (e) {
      debugPrint("Error checking permissions: $e");
      setState(() => _isCheckingPermissions = false);
    }
  }

  // 🔹 ตรวจสอบ Bluetooth permission ตามเวอร์ชัน Android
  Future<bool> _checkBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;

      return bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted;
    } else {
      final bluetoothStatus = await Permission.bluetooth.status;
      return bluetoothStatus.isGranted;
    }
  }

  // 🔹 ขอ permission ทั้งหมด
  Future<void> _requestAllPermissions() async {
    setState(() => _isRequestingPermissions = true);

    try {
      await _requestBluetoothPermission();
      await _requestLocationPermission();
      await _requestNotificationPermission();

      await _checkCurrentPermissions();

      if (_isBluetoothGranted && _isLocationGranted && _isNotificationGranted) {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/device-dashboard');
        }
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      _showPermissionErrorDialog();
    } finally {
      setState(() => _isRequestingPermissions = false);
    }
  }

  // 🔹 ขอ Bluetooth (Android 12+ ใช้ Scan + Connect)
  Future<void> _requestBluetoothPermission() async {
    try {
      if (Platform.isAndroid) {
        final scanStatus = await Permission.bluetoothScan.request();
        final connectStatus = await Permission.bluetoothConnect.request();

        setState(() {
          _isBluetoothGranted =
              scanStatus.isGranted && connectStatus.isGranted;
        });
      } else {
        final status = await Permission.bluetooth.request();
        setState(() => _isBluetoothGranted = status.isGranted);
      }
    } catch (e) {
      debugPrint("Bluetooth permission error: $e");
      setState(() => _isBluetoothGranted = false);
    }
  }

  // 🔹 ขอ Location (จำเป็นสำหรับ BLE scan)
  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      setState(() => _isLocationGranted = status.isGranted);
    } catch (e) {
      debugPrint("Location permission error: $e");
      setState(() => _isLocationGranted = false);
    }
  }

  // 🔹 ขอ Notification
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() => _isNotificationGranted = status.isGranted);
  }

  // 🔹 Dialog กรณี denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningState,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Permissions Required',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Some permissions were denied. For Bluetooth functionality, please ensure:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '• Enable Location services (required for Bluetooth scanning)\n'
                '• Allow Bluetooth access\n'
                '• Enable notifications for connection alerts',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMediumEmphasisLight),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: AppTheme.accentHighlight),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestAllPermissions();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Dialog กรณี error
  void _showPermissionErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.errorCritical,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Permission Error',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'An error occurred while requesting permissions. Please ensure your device supports Bluetooth and try again.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMediumEmphasisLight),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestAllPermissions();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  bool get _allPermissionsGranted =>
      _isBluetoothGranted && _isLocationGranted && _isNotificationGranted;

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, '/splash-screen');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.textHighEmphasisLight,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Setup Permissions',
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textHighEmphasisLight,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),

              SizedBox(height: 6.h),
              const AnimatedBluetoothIconWidget(),
              SizedBox(height: 4.h),

              Text(
                'Enable Heart Rate Monitoring',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHighEmphasisLight,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                'Grant the following permissions to connect with Polar Sense HR monitors and start monitoring heart rates in real-time.',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 4.h),

              if (_isCheckingPermissions)
                Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.accentHighlight,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Checking permissions...',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                )
              else ...[
                PermissionCardWidget(
                  title: 'Bluetooth Access',
                  description: 'Connect to Polar Sense HR monitors',
                  iconName: 'bluetooth',
                  isGranted: _isBluetoothGranted,
                  onTap:
                      _isBluetoothGranted ? null : _requestBluetoothPermission,
                ),
                PermissionCardWidget(
                  title: 'Location Access',
                  description: 'Required for BLE device scanning (Android)',
                  iconName: 'location_on',
                  isGranted: _isLocationGranted,
                  onTap:
                      _isLocationGranted ? null : _requestLocationPermission,
                ),
                PermissionCardWidget(
                  title: 'Notifications',
                  description: 'Connection alerts and status updates',
                  iconName: 'notifications',
                  isGranted: _isNotificationGranted,
                  onTap:
                      _isNotificationGranted
                          ? null
                          : _requestNotificationPermission,
                ),
              ],

              SizedBox(height: 4.h),

              // Grant button
              if (!_isCheckingPermissions)
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isRequestingPermissions || _allPermissionsGranted
                        ? null
                        : _requestAllPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allPermissionsGranted
                          ? AppTheme.connectionSuccess
                          : AppTheme.accentHighlight,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isRequestingPermissions
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Requesting Permissions...',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: _allPermissionsGranted
                                    ? 'check_circle'
                                    : 'security',
                                color: Colors.white,
                                size: 5.w,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                _allPermissionsGranted
                                    ? 'All Permissions Granted'
                                    : 'Grant Permissions',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

              SizedBox(height: 3.h),

              if (_allPermissionsGranted && !_isCheckingPermissions)
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/device-dashboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentHighlight,
                      side: BorderSide(
                        color: AppTheme.accentHighlight,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue to Dashboard',
                          style:
                              AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.accentHighlight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'arrow_forward',
                          color: AppTheme.accentHighlight,
                          size: 5.w,
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 4.h),
              const ExpandableInfoWidget(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
