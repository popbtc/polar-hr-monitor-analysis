import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DisplayOptionsWidget extends StatelessWidget {
  final String selectedLayout;
  final bool showDeviceNames;
  final bool useHeartRateColors;
  final Function(String) onLayoutChanged;
  final Function(bool) onDeviceNamesToggled;
  final Function(bool) onHeartRateColorsToggled;

  const DisplayOptionsWidget({
    Key? key,
    required this.selectedLayout,
    required this.showDeviceNames,
    required this.useHeartRateColors,
    required this.onLayoutChanged,
    required this.onDeviceNamesToggled,
    required this.onHeartRateColorsToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display Options',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Layout selection
          _buildSectionTitle('Layout'),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildLayoutOption('grid', 'Grid', 'grid_view'),
              SizedBox(width: 3.w),
              _buildLayoutOption('list', 'List', 'list'),
              SizedBox(width: 3.w),
              _buildLayoutOption('fullscreen', 'Full Screen', 'fullscreen'),
            ],
          ),

          SizedBox(height: 3.h),

          // Toggle options
          _buildToggleOption(
            'Device Names',
            'Show device names on display',
            showDeviceNames,
            onDeviceNamesToggled,
          ),

          SizedBox(height: 2.h),

          _buildToggleOption(
            'Heart Rate Colors',
            'Use zone colors for heart rate values',
            useHeartRateColors,
            onHeartRateColorsToggled,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLayoutOption(String value, String label, String iconName) {
    final isSelected = selectedLayout == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onLayoutChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentHighlight.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentHighlight
                  : AppTheme.lightTheme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? AppTheme.accentHighlight
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.accentHighlight
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.connectionSuccess,
          inactiveThumbColor: AppTheme.inactiveDevice,
          inactiveTrackColor: AppTheme.inactiveDevice.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
