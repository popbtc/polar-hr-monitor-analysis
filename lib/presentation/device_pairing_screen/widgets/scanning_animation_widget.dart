import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanningAnimationWidget extends StatefulWidget {
  final bool isScanning;

  const ScanningAnimationWidget({
    Key? key,
    required this.isScanning,
  }) : super(key: key);

  @override
  State<ScanningAnimationWidget> createState() =>
      _ScanningAnimationWidgetState();
}

class _ScanningAnimationWidgetState extends State<ScanningAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isScanning) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ScanningAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      height: 60.w,
      child: widget.isScanning
          ? AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer expanding circle
                    Container(
                      width: 40.w * _scaleAnimation.value,
                      height: 40.w * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentHighlight.withValues(
                            alpha: 1.0 - (_scaleAnimation.value - 0.5) / 1.5,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    // Middle expanding circle
                    Container(
                      width: 30.w * _scaleAnimation.value * 0.7,
                      height: 30.w * _scaleAnimation.value * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentHighlight.withValues(
                            alpha: 1.0 - (_scaleAnimation.value - 0.5) / 1.2,
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner static circle with Bluetooth icon
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentHighlight,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'bluetooth',
                          color: AppTheme.lightTheme.colorScheme.surface,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.inactiveDevice,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'bluetooth_disabled',
                  color: AppTheme.lightTheme.colorScheme.surface,
                  size: 6.w,
                ),
              ),
            ),
    );
  }
}
