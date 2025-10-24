import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final int connectedDevices;
  final int totalDevices;
  final bool isScanning;

  const ConnectionStatusWidget({
    Key? key,
    required this.connectedDevices,
    required this.totalDevices,
    this.isScanning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Connection status indicator
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: connectedDevices > 0
                  ? AppTheme.connectionSuccess
                  : AppTheme.inactiveDevice,
              shape: BoxShape.circle,
            ),
            child: isScanning
                ? SizedBox(
                    width: 2.w,
                    height: 2.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.surface,
                      ),
                    ),
                  )
                : null,
          ),

          SizedBox(width: 3.w),

          // Connection text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connectedDevices > 0
                      ? '$connectedDevices Device${connectedDevices > 1 ? 's' : ''} Connected'
                      : 'No Devices Connected',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: connectedDevices > 0
                        ? AppTheme.connectionSuccess
                        : AppTheme.textMediumEmphasisLight,
                  ),
                ),
                if (isScanning)
                  Text(
                    'Scanning for devices...',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentHighlight,
                    ),
                  )
                else if (totalDevices > 0)
                  Text(
                    '$totalDevices total device${totalDevices > 1 ? 's' : ''} paired',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                  ),
              ],
            ),
          ),

          // Bluetooth icon
          CustomIconWidget(
            iconName: 'bluetooth',
            color: connectedDevices > 0
                ? AppTheme.connectionSuccess
                : AppTheme.inactiveDevice,
            size: 24,
          ),
        ],
      ),
    );
  }
}
