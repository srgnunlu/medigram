import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/presentation/screens/premium/subscription_screen.dart';

class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final bool isPremiumContent;
  final bool showBlur;

  const PremiumLockWidget({
    super.key,
    required this.child,
    this.isPremiumContent = false,
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremiumContent) {
      return child;
    }

    return Stack(
      children: [
        // Blurred content
        if (showBlur)
          Opacity(
            opacity: 0.3,
            child: child,
          )
        else
          child,

        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.9),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 40,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  Text(
                    'Premium İçerik',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),

                  const SizedBox(height: AppConstants.spacingS),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXL,
                    ),
                    child: Text(
                      'Bu içeriğe erişmek için premium üyelik gereklidir',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const SubscriptionScreen());
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Premium\'a Geç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL,
                        vertical: AppConstants.spacingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
