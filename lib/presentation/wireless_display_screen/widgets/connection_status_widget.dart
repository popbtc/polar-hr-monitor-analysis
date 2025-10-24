import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final String status;
  final String? connectedDeviceName;
  final VoidCallback? onStopCasting;

  const ConnectionStatusWidget({
    Key? key,
    required this.status,
    this.connectedDeviceName,
    this.onStopCasting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildStatusIcon(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                    if (connectedDeviceName != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        connectedDeviceName!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (status == 'connected' && onStopCasting != null)
                ElevatedButton(
                  onPressed: onStopCasting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorCritical,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Stop',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (status == 'searching') ...[
            SizedBox(height: 2.h),
            LinearProgressIndicator(
              backgroundColor: _getStatusColor().withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
            SizedBox(height: 1.h),
            Text(
              'Scanning for available devices...',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (status == 'failed') ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorCritical.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Failed',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.errorCritical,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Unable to connect to the selected device. Please check your network connection and try again.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case 'searching':
        return SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case 'connecting':
        return SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case 'connected':
        return CustomIconWidget(
          iconName: 'check',
          color: Colors.white,
          size: 6.w,
        );
      case 'failed':
        return CustomIconWidget(
          iconName: 'error',
          color: Colors.white,
          size: 6.w,
        );
      default:
        return CustomIconWidget(
          iconName: 'cast',
          color: Colors.white,
          size: 6.w,
        );
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'searching':
        return 'Searching for Devices';
      case 'connecting':
        return 'Connecting...';
      case 'connected':
        return 'Now Casting';
      case 'failed':
        return 'Connection Failed';
      default:
        return 'Ready to Cast';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'searching':
        return AppTheme.accentHighlight;
      case 'connecting':
        return AppTheme.warningState;
      case 'connected':
        return AppTheme.connectionSuccess;
      case 'failed':
        return AppTheme.errorCritical;
      default:
        return AppTheme.inactiveDevice;
    }
  }
}
