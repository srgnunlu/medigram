import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/presentation/controllers/premium_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premiumController = Get.put(PremiumController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Üyelik'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  size: 50,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingXL),

            // Title
            Text(
              'Medigram Premium',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingM),

            Text(
              'Tüm premium içeriklere sınırsız erişim',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingXL),

            // Features
            _FeatureTile(
              icon: Icons.lock_open,
              title: 'Tüm Premium İçerikler',
              subtitle: 'Uzman doktorların hazırladığı özel içeriklere erişin',
            ),
            _FeatureTile(
              icon: Icons.ads_click_off,
              title: 'Reklamsız Deneyim',
              subtitle: 'Kesintisiz okuma ve öğrenme deneyimi',
            ),
            _FeatureTile(
              icon: Icons.cloud_download,
              title: 'Offline Erişim',
              subtitle: 'İçerikleri indirin, internet olmadan okuyun',
            ),
            _FeatureTile(
              icon: Icons.tips_and_updates,
              title: 'Erken Erişim',
              subtitle: 'Yeni içeriklere ilk siz ulaşın',
            ),
            _FeatureTile(
              icon: Icons.support_agent,
              title: 'Öncelikli Destek',
              subtitle: 'Sorularınız için hızlı yanıt alın',
            ),

            const SizedBox(height: AppConstants.spacingXL),

            // Plans
            _PlanCard(
              plan: 'monthly',
              price: PremiumController.getPlanPrice('monthly'),
              isPopular: false,
              onTap: () => premiumController.startCheckout('monthly'),
            ),

            const SizedBox(height: AppConstants.spacingM),

            _PlanCard(
              plan: 'yearly',
              price: PremiumController.getPlanPrice('yearly'),
              isPopular: true,
              onTap: () => premiumController.startCheckout('yearly'),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Terms
            Text(
              'Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String plan;
  final double price;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.price,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final planName = PremiumController.getPlanName(plan);
    final monthlyPrice = plan == 'yearly' ? price / 12 : price;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: isPopular ? AppColors.accentGradient : null,
            color: isPopular ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: isPopular
                ? null
                : Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          planName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (plan == 'yearly')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '%16 İndirim',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₺${price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ ${plan == 'monthly' ? 'ay' : 'yıl'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (plan == 'yearly') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Aylık ₺${monthlyPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isPopular
                                  ? AppColors.textPrimary.withOpacity(0.8)
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Popüler',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
