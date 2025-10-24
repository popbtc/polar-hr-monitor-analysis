import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceNameBottomSheetWidget extends StatefulWidget {
  final String defaultName;
  final Function(String) onNameConfirmed;

  const DeviceNameBottomSheetWidget({
    Key? key,
    required this.defaultName,
    required this.onNameConfirmed,
  }) : super(key: key);

  @override
  State<DeviceNameBottomSheetWidget> createState() =>
      _DeviceNameBottomSheetWidgetState();
}

class _DeviceNameBottomSheetWidgetState
    extends State<DeviceNameBottomSheetWidget> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    // Auto-focus and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirmName() {
    final String trimmedName = _nameController.text.trim();
    if (trimmedName.isNotEmpty) {
      widget.onNameConfirmed(trimmedName);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 6.w,
        right: 6.w,
        top: 4.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.inactiveDevice,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Success animation and title
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.connectionSuccess.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.connectionSuccess,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Connected!',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.connectionSuccess,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Give your device a custom name',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Device name input
          Text(
            'Device Name',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _nameController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Enter device name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.textMediumEmphasisLight,
                  size: 5.w,
                ),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _nameController.clear();
                        setState(() {});
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.textMediumEmphasisLight,
                        size: 5.w,
                      ),
                    )
                  : null,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirmName(),
            onChanged: (value) => setState(() {}),
            maxLength: 20,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) {
              return Text(
                '$currentLength/${maxLength ?? 0}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDisabledLight,
                ),
              );
            },
          ),
          SizedBox(height: 3.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    side: BorderSide(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isNotEmpty
                      ? _confirmName
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentHighlight,
                    foregroundColor: AppTheme.lightTheme.colorScheme.surface,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    disabledBackgroundColor: AppTheme.inactiveDevice,
                  ),
                  child: Text(
                    'Confirm',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
