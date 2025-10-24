import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceContextMenuWidget extends StatelessWidget {
  final String deviceName;
  final VoidCallback onRename;
  final VoidCallback onRemove;
  final VoidCallback onViewHistory;
  final VoidCallback onDismiss;

  const DeviceContextMenuWidget({
    Key? key,
    required this.deviceName,
    required this.onRename,
    required this.onRemove,
    required this.onViewHistory,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            width: 80.w,
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'favorite',
                        color: AppTheme.heartRateActive,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          deviceName,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDismiss,
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.textMediumEmphasisLight,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu options
                _buildMenuOption(
                  icon: 'edit',
                  title: 'Rename Device',
                  subtitle: 'Change the display name',
                  onTap: () {
                    onDismiss();
                    onRename();
                  },
                ),

                _buildMenuOption(
                  icon: 'history',
                  title: 'View History',
                  subtitle: 'See past heart rate data',
                  onTap: () {
                    onDismiss();
                    onViewHistory();
                  },
                ),

                _buildMenuOption(
                  icon: 'delete',
                  title: 'Remove Device',
                  subtitle: 'Delete from saved list',
                  onTap: () {
                    onDismiss();
                    onRemove();
                  },
                  isDestructive: true,
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive
                  ? AppTheme.errorCritical
                  : AppTheme.accentHighlight,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppTheme.errorCritical
                          : AppTheme.textHighEmphasisLight,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textDisabledLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
