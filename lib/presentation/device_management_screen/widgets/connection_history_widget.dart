import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionHistoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> historyData;

  const ConnectionHistoryWidget({
    super.key,
    required this.historyData,
  });

  @override
  State<ConnectionHistoryWidget> createState() =>
      _ConnectionHistoryWidgetState();
}

class _ConnectionHistoryWidgetState extends State<ConnectionHistoryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.accentHighlight,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Connection History',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CustomIconWidget(
                      iconName: _isExpanded ? 'expand_less' : 'expand_more',
                      color: AppTheme.textMediumEmphasisLight,
                      size: 6.w,
                    ),
                  ],
                ),
              ),
              if (_isExpanded) ...[
                SizedBox(height: 2.h),
                _buildHistoryTimeline(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    if (widget.historyData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'timeline',
              color: AppTheme.inactiveDevice,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No connection history available',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 40.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.historyData.length,
        itemBuilder: (context, index) {
          final historyItem = widget.historyData[index];
          final bool isLast = index == widget.historyData.length - 1;

          return _buildHistoryItem(historyItem, isLast);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isLast) {
    final String event = item['event'] ?? 'unknown';
    final String timestamp = item['timestamp'] ?? 'Unknown time';
    final String deviceName = item['deviceName'] ?? 'Unknown Device';
    final String? duration = item['duration'];
    final String? reason = item['reason'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: _getEventColor(event),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 0.5.w,
                height: 8.h,
                color: AppTheme.borderColor,
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getEventTitle(event),
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: _getEventColor(event),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      timestamp,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  deviceName,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (duration != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.textMediumEmphasisLight,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Duration: \$duration',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ],
                if (reason != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.textMediumEmphasisLight,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          reason,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getEventColor(String event) {
    switch (event.toLowerCase()) {
      case 'connected':
        return AppTheme.connectionSuccess;
      case 'disconnected':
        return AppTheme.inactiveDevice;
      case 'error':
        return AppTheme.errorCritical;
      case 'reconnected':
        return AppTheme.accentHighlight;
      default:
        return AppTheme.textMediumEmphasisLight;
    }
  }

  String _getEventTitle(String event) {
    switch (event.toLowerCase()) {
      case 'connected':
        return 'Device Connected';
      case 'disconnected':
        return 'Device Disconnected';
      case 'error':
        return 'Connection Error';
      case 'reconnected':
        return 'Device Reconnected';
      default:
        return 'Unknown Event';
    }
  }
}
