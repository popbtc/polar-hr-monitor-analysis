import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CastingPreviewWidget extends StatelessWidget {
  final String layout;
  final bool showDeviceNames;
  final bool useHeartRateColors;
  final List<Map<String, dynamic>> heartRateData;

  const CastingPreviewWidget({
    Key? key,
    required this.layout,
    required this.showDeviceNames,
    required this.useHeartRateColors,
    required this.heartRateData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Preview',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.connectionSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.connectionSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Live',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.connectionSuccess,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Preview container
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _buildPreviewContent(),
            ),
          ),

          SizedBox(height: 1.h),

          // Preview info
          Text(
            'This is how your heart rate data will appear on the connected display',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    switch (layout) {
      case 'grid':
        return _buildGridPreview();
      case 'list':
        return _buildListPreview();
      case 'fullscreen':
        return _buildFullscreenPreview();
      default:
        return _buildGridPreview();
    }
  }

  Widget _buildGridPreview() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: heartRateData.length > 4 ? 3 : 2,
          crossAxisSpacing: 1.w,
          mainAxisSpacing: 1.h,
          childAspectRatio: 1.2,
        ),
        itemCount: heartRateData.length > 6 ? 6 : heartRateData.length,
        itemBuilder: (context, index) {
          final device = heartRateData[index];
          return _buildMiniDeviceCard(device);
        },
      ),
    );
  }

  Widget _buildListPreview() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: heartRateData.length > 4 ? 4 : heartRateData.length,
        itemBuilder: (context, index) {
          final device = heartRateData[index];
          return Container(
            margin: EdgeInsets.only(bottom: 1.h),
            child: _buildMiniListItem(device),
          );
        },
      ),
    );
  }

  Widget _buildFullscreenPreview() {
    if (heartRateData.isEmpty) {
      return const Center(
        child: Text('No devices connected'),
      );
    }

    final device = heartRateData.first;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showDeviceNames) ...[
            Text(
              device['deviceName'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
          ],
          Text(
            '${device['heartRate']}',
            style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
              color: useHeartRateColors
                  ? AppTheme.getHeartRateZoneColor(device['heartRate'] as int)
                  : AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'BPM',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDeviceCard(Map<String, dynamic> device) {
    final heartRate = device['heartRate'] as int;
    final deviceName = device['deviceName'] as String;

    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showDeviceNames) ...[
            Text(
              deviceName,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontSize: 8.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
          ],
          Text(
            '$heartRate',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: useHeartRateColors
                  ? AppTheme.getHeartRateZoneColor(heartRate)
                  : AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          Text(
            'BPM',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 7.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniListItem(Map<String, dynamic> device) {
    final heartRate = device['heartRate'] as int;
    final deviceName = device['deviceName'] as String;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          if (showDeviceNames) ...[
            Expanded(
              child: Text(
                deviceName,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 8.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          Text(
            '$heartRate BPM',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: useHeartRateColors
                  ? AppTheme.getHeartRateZoneColor(heartRate)
                  : AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
