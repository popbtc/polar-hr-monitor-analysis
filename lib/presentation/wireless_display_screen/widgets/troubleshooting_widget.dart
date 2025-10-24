import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TroubleshootingWidget extends StatefulWidget {
  const TroubleshootingWidget({Key? key}) : super(key: key);

  @override
  State<TroubleshootingWidget> createState() => _TroubleshootingWidgetState();
}

class _TroubleshootingWidgetState extends State<TroubleshootingWidget> {
  bool _isExpanded = false;

  final List<Map<String, String>> _troubleshootingItems = [
    {
      'issue': 'Device not appearing in list',
      'solution':
          'Ensure your device and phone are connected to the same WiFi network. Restart both devices if needed.',
    },
    {
      'issue': 'Connection keeps dropping',
      'solution':
          'Check WiFi signal strength. Move closer to your router or restart your network connection.',
    },
    {
      'issue': 'Poor display quality',
      'solution':
          'Reduce the number of connected heart rate monitors or switch to a simpler layout option.',
    },
    {
      'issue': 'Audio/Video sync issues',
      'solution':
          'Close other apps using network bandwidth. Consider using a wired connection if available.',
    },
    {
      'issue': 'Chromecast not working',
      'solution':
          'Ensure Google Home app is installed and Chromecast is set up properly on your network.',
    },
    {
      'issue': 'AirPlay connection failed',
      'solution':
          'Check that AirPlay is enabled on your Apple TV and both devices are on the same network.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.accentHighlight,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Troubleshooting Guide',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 2.h),
            Container(
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
                    'Common Issues & Solutions',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentHighlight,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  ..._troubleshootingItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Column(
                      children: [
                        _buildTroubleshootingItem(
                          item['issue']!,
                          item['solution']!,
                        ),
                        if (index < _troubleshootingItems.length - 1)
                          SizedBox(height: 2.h),
                      ],
                    );
                  }).toList(),

                  SizedBox(height: 3.h),

                  // Network requirements
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentHighlight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentHighlight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'wifi',
                              color: AppTheme.accentHighlight,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Network Requirements',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.accentHighlight,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '• Both devices must be on the same WiFi network\n'
                          '• Stable internet connection recommended\n'
                          '• 5GHz WiFi preferred for better performance\n'
                          '• Ensure firewall allows casting protocols',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildTroubleshootingItem(String issue, String solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 0.5.h),
              width: 1.5.w,
              height: 1.5.w,
              decoration: const BoxDecoration(
                color: AppTheme.errorCritical,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                issue,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 3.5.w),
          child: Text(
            solution,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
