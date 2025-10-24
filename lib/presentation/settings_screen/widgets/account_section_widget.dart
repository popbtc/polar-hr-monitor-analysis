import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountSectionWidget extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onProfileManagement;

  const AccountSectionWidget({
    Key? key,
    required this.onSignIn,
    required this.onProfileManagement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock user state - in real app, this would come from authentication service
    final bool isSignedIn = false;
    final String? userEmail = isSignedIn ? 'user@example.com' : null;
    final String? userName = isSignedIn ? 'John Doe' : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          if (!isSignedIn) ...[
            // Sign in state
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.inactiveDevice.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.inactiveDevice,
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.inactiveDevice,
                    size: 24,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Sign in to sync your data across devices',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onSignIn,
                  child: Text('Sign In'),
                ),
              ],
            ),
          ] else ...[
            // Signed in state
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.connectionSuccess.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.connectionSuccess,
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.connectionSuccess,
                    size: 24,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? 'User',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        userEmail ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onProfileManagement,
                  child: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.textDisabledLight,
                    size: 20,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Account management options for signed in users
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle profile editing
                    },
                    child: Text('Edit Profile'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle sign out
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.warningState),
                      foregroundColor: AppTheme.warningState,
                    ),
                    child: Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
