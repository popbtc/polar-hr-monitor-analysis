import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onViewHistory;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAutoReconnect;
  final VoidCallback? onToggleNotifications;
  final VoidCallback? onResetConnection;
  final VoidCallback? onExportData;
  final VoidCallback? onDeviceInfo;
  final bool isExpanded;

  const DeviceCardWidget({
    super.key,
    required this.device,
    this.onTap,
    this.onRename,
    this.onViewHistory,
    this.onDelete,
    this.onToggleAutoReconnect,
    this.onToggleNotifications,
    this.onResetConnection,
    this.onExportData,
    this.onDeviceInfo,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    print("🛠️ Using MANAGEMENT DeviceCardWidget for ${device['name']}");

    final String status = device['status'] ?? 'disconnected';
    final int heartRate = device['heartRate'] ?? 0;
    final int battery = device['battery'] ?? 0;
    final String lastSeen = device['lastSeen'] ?? 'Never';
    final bool autoReconnect = device['autoReconnect'] ?? false;
    final bool notifications = device['notifications'] ?? true;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(device['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onRename?.call(),
              backgroundColor: AppTheme.accentHighlight,
              foregroundColor: AppTheme.lightTheme.colorScheme.surface,
              icon: Icons.edit,
              label: 'Rename',
              borderRadius: BorderRadius.circular(8.0),
            ),
            SlidableAction(
              onPressed: (context) => onViewHistory?.call(),
              backgroundColor: AppTheme.connectionSuccess,
              foregroundColor: AppTheme.lightTheme.colorScheme.surface,
              icon: Icons.history,
              label: 'History',
              borderRadius: BorderRadius.circular(8.0),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onDelete?.call(),
              backgroundColor: AppTheme.errorCritical,
              foregroundColor: AppTheme.lightTheme.colorScheme.surface,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(8.0),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: _getStatusColor(status).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceHeader(status, heartRate, battery),
                  SizedBox(height: 2.h),
                  _buildDeviceInfo(lastSeen),
                  if (isExpanded) ...[
                    SizedBox(height: 2.h),
                    _buildExpandedContent(),
                  ],
                  SizedBox(height: 2.h),
                  _buildDeviceControls(autoReconnect, notifications),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(String status, int heartRate, int battery) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CustomIconWidget(
            iconName: 'favorite',
            color: _getStatusColor(status),
            size: 6.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device['name'] ?? 'Unknown Device',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _getStatusText(status),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (status == 'connected' && heartRate > 0) ...[
              Text(
                '\$heartRate BPM',
                style: AppTheme.dataTextStyle(
                  isLight: true,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'battery_std',
                  color: _getBatteryColor(battery),
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  '\$battery%',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getBatteryColor(battery),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(String lastSeen) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'access_time',
          color: AppTheme.textMediumEmphasisLight,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          'Last seen: \$lastSeen',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasisLight,
          ),
        ),
        Spacer(),
        if (isExpanded)
          CustomIconWidget(
            iconName: 'expand_less',
            color: AppTheme.textMediumEmphasisLight,
            size: 5.w,
          )
        else
          CustomIconWidget(
            iconName: 'expand_more',
            color: AppTheme.textMediumEmphasisLight,
            size: 5.w,
          ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('MAC Address', device['macAddress'] ?? 'Unknown'),
          SizedBox(height: 1.h),
          _buildDetailRow('Firmware', device['firmware'] ?? 'Unknown'),
          SizedBox(height: 1.h),
          _buildDetailRow(
              'Connection Duration', device['connectionDuration'] ?? '0 min'),
          SizedBox(height: 2.h),
          _buildSignalStrengthGraph(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasisLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalStrengthGraph() {
    final int signalStrength = device['signalStrength'] ?? 75;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signal Strength',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasisLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: signalStrength / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getSignalColor(signalStrength),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '\$signalStrength%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceControls(bool autoReconnect, bool notifications) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'sync',
                color: AppTheme.textMediumEmphasisLight,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Auto-reconnect',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Spacer(),
              Switch(
                value: autoReconnect,
                onChanged: (value) => onToggleAutoReconnect?.call(),
                activeColor: AppTheme.connectionSuccess,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.textMediumEmphasisLight,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Notifications',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Spacer(),
              Switch(
                value: notifications,
                onChanged: (value) => onToggleNotifications?.call(),
                activeColor: AppTheme.accentHighlight,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.accentHighlight,
                size: 6.w,
              ),
              title: Text('Reset Connection'),
              onTap: () {
                Navigator.pop(context);
                onResetConnection?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: AppTheme.connectionSuccess,
                size: 6.w,
              ),
              title: Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                onExportData?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info',
                color: AppTheme.textMediumEmphasisLight,
                size: 6.w,
              ),
              title: Text('Device Info'),
              onTap: () {
                Navigator.pop(context);
                onDeviceInfo?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return AppTheme.connectionSuccess;
      case 'connecting':
        return AppTheme.warningState;
      case 'error':
        return AppTheme.errorCritical;
      default:
        return AppTheme.inactiveDevice;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return 'Connected';
      case 'connecting':
        return 'Connecting...';
      case 'error':
        return 'Connection Error';
      default:
        return 'Disconnected';
    }
  }

  Color _getBatteryColor(int battery) {
    if (battery > 50) return AppTheme.connectionSuccess;
    if (battery > 20) return AppTheme.warningState;
    return AppTheme.errorCritical;
  }

  Color _getSignalColor(int signal) {
    if (signal > 70) return AppTheme.connectionSuccess;
    if (signal > 40) return AppTheme.warningState;
    return AppTheme.errorCritical;
  }
}
