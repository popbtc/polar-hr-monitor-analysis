import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CastingDeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onTap;
  final bool isConnecting;

  const CastingDeviceCard({
    Key? key,
    required this.device,
    required this.onTap,
    this.isConnecting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = device['type'] as String;
    final deviceName = device['name'] as String;
    final signalStrength = device['signalStrength'] as int;
    final isConnected = device['isConnected'] as bool? ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isConnecting ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isConnected
                    ? AppTheme.connectionSuccess
                    : AppTheme.lightTheme.colorScheme.outline,
                width: isConnected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Device type icon
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color:
                        _getDeviceTypeColor(deviceType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getDeviceTypeIcon(deviceType),
                      color: _getDeviceTypeColor(deviceType),
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Device info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            deviceType,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          // Signal strength indicator
                          Row(
                            children: List.generate(3, (index) {
                              return Container(
                                width: 0.8.w,
                                height: (index + 1) * 0.8.h,
                                margin: EdgeInsets.only(right: 0.5.w),
                                decoration: BoxDecoration(
                                  color: index < (signalStrength / 33).ceil()
                                      ? AppTheme.connectionSuccess
                                      : AppTheme.inactiveDevice,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Connection status
                if (isConnecting)
                  SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentHighlight,
                      ),
                    ),
                  )
                else if (isConnected)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppTheme.connectionSuccess,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 4.w,
                      ),
                    ),
                  )
                else
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDeviceTypeIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'chromecast':
        return 'cast';
      case 'apple tv':
        return 'tv';
      case 'miracast':
        return 'screen_share';
      default:
        return 'devices';
    }
  }

  Color _getDeviceTypeColor(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'chromecast':
        return const Color(0xFF4285F4); // Google Blue
      case 'apple tv':
        return const Color(0xFF000000); // Apple Black
      case 'miracast':
        return AppTheme.accentHighlight;
      default:
        return AppTheme.secondaryLight;
    }
  }
}
