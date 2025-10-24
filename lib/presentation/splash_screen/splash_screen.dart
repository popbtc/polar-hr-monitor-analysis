import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/permissions.dart'; // ✅ ใช้คลาส Permissions ใหม่

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  String _statusMessage = "Initializing...";
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      setState(() => _statusMessage = "Checking device compatibility...");
      await Future.delayed(const Duration(milliseconds: 400));

      bool bleSupported = await _checkBLECapability();
      if (!bleSupported) {
        _showCompatibilityError();
        return;
      }

      // 🔹 ตรวจ permission โดยใช้ Permissions class ใหม่
      setState(() => _statusMessage = "Checking permissions...");
      await Future.delayed(const Duration(milliseconds: 400));

      bool hasPermissions = await Permissions.checkAll();

      setState(() => _statusMessage = "Loading device profiles...");
      await Future.delayed(const Duration(milliseconds: 400));
      await _loadDeviceHistory();

      setState(() => _statusMessage = "Preparing HR monitors...");
      await Future.delayed(const Duration(milliseconds: 400));
      await _preparePolarProfiles();

      setState(() {
        _statusMessage = "Ready!";
        _isInitializing = false;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      // 🔹 ไปหน้าต่อไป
      if (hasPermissions) {
        _navigateToDeviceDashboard();
      } else {
        _navigateToPermissionRequest();
      }
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<bool> _checkBLECapability() async {
    // จำลอง BLE capability check
    return true;
  }

  Future<void> _loadDeviceHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _preparePolarProfiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _showCompatibilityError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.errorCritical,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Device Not Compatible',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.errorCritical,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Your device does not support Bluetooth Low Energy (BLE), which is required for connecting to Polar Sense HR monitors.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: Text(
                'Exit App',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.errorCritical,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleInitializationError(dynamic error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningState,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Initialization Error',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.warningState,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'There was an issue initializing the app. Please try again.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startInitialization();
              },
              child: Text(
                'Retry',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentHighlight,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDeviceDashboard() {
    _fadeController.forward().then((_) {
      Navigator.pushReplacementNamed(context, '/device-dashboard');
    });
  }

  void _navigateToPermissionRequest() {
    _fadeController.forward().then((_) {
      Navigator.pushReplacementNamed(context, '/permission-request-screen');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.colorScheme.surface,
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
                AppTheme.accentHighlight.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.shadowColor,
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'favorite',
                                        color: AppTheme.heartRateActive,
                                        size: 8.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      CustomIconWidget(
                                        iconName: 'bluetooth',
                                        color: AppTheme.accentHighlight,
                                        size: 6.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'PolarSync',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Monitor',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  color: AppTheme.accentHighlight,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isInitializing) ...[
                        SizedBox(
                          width: 8.w,
                          height: 8.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentHighlight,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Column(
                    children: [
                      Text(
                        'Professional Heart Rate Monitoring',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDisabledLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'security',
                            color: AppTheme.connectionSuccess,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Secure BLE Connection',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.connectionSuccess,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
