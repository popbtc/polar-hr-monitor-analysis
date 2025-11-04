import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'dart:ui';

class DeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> deviceData;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const DeviceCardWidget({
    Key? key,
    required this.deviceData,
    this.onLongPress,
    this.onTap,
  }) : super(key: key);

  Color _getHeartRateZoneColor(int heartRate, bool isConnected) {
    if (!isConnected) return AppTheme.inactiveDevice;
    if (heartRate < 90) return Colors.blueAccent;      // 💙 Rest
    if (heartRate < 120) return Colors.greenAccent;     // 💚 Warm-up
    if (heartRate < 140) return Colors.yellowAccent;    // 💛 Fat Burn
    if (heartRate < 170) return Colors.orangeAccent;    // 🧡 Cardio
    return Colors.redAccent;                            // ❤️ Peak
  }


  @override
  Widget build(BuildContext context) {
    final bool isConnected = deviceData['isConnected'] as bool? ?? false;
    final dynamic hrValue = deviceData['heartRate'];
    final int? heartRate = (hrValue is int) ? hrValue : null;
    final String deviceName = deviceData['name'] as String? ?? 'Unknown Device';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 42.w,
        height: 24.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? _getHeartRateZoneColor(heartRate ?? 0, isConnected).withOpacity(0.5)
                : AppTheme.borderColor,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Device name
              Text(
                deviceName,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),

              // ❤️ Heart Rate display
              Text(
                (heartRate != null && isConnected)
                    ? heartRate.toString()
                    : '--',
                style: AppTheme.dataTextStyle(
                  isLight: true,
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  color: _getHeartRateZoneColor(heartRate ?? 0, isConnected),
                ),
              ),
              Text(
                'BPM',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 1.h),

              // 🔘 Connection indicator
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppTheme.connectionSuccess
                      : AppTheme.inactiveDevice,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
