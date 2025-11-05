import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/core/utils/date_formatter.dart';
import 'package:medigram/presentation/controllers/medical_card_controller.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';
import 'package:medigram/presentation/controllers/premium_controller.dart';
import 'package:medigram/presentation/screens/card/card_detail_screen.dart';
import 'package:medigram/presentation/widgets/common/premium_lock_widget.dart';

class MedicalCardWidget extends StatelessWidget {
  final MedicalCard card;

  const MedicalCardWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final cardController = Get.find<MedicalCardController>();
    final authController = Get.find<AuthController>();
    final premiumController = Get.put(PremiumController());

    return GestureDetector(
      onTap: () {
        Get.to(() => CardDetailScreen(card: card));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.getCategoryColor(card.category),
                  child: Text(
                    card.author.isNotEmpty ? card.author[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.author,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        DateFormatter.formatDateTime(card.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Category chip
                Chip(
                  label: Text(
                    card.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.getCategoryColor(card.category),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // Image
          if (card.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: card.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: AppColors.surfaceLight,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: AppColors.surfaceLight,
                child: const Icon(Icons.error, color: AppColors.error),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Obx(() {
              final isPremiumUser = premiumController.isPremium;
              final shouldLock = card.isPremium && !isPremiumUser;

              return PremiumLockWidget(
                isPremiumContent: shouldLock,
                showBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium badge
                    if (card.isPremium)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: AppConstants.spacingXS),
                            Text(
                              'Premium İçerik',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    // Title
                    Text(
                      card.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingS),

                    // Content preview
                    Text(
                      card.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Source
                    if (card.source.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.source,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Expanded(
                            child: Text(
                              'Kaynak: ${card.source}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            child: Row(
              children: [
                // Like button
                Obx(() {
                  final currentUser = authController.currentUser;
                  final isLiked = currentUser != null &&
                      card.isLikedBy(currentUser.id.toString());

                  return InkWell(
                    onTap: () => cardController.toggleLike(card.id),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? AppColors.error : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '${card.likes.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(width: AppConstants.spacingL),

                // Comment button
                InkWell(
                  onTap: () {
                    // TODO: Navigate to comments
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '${card.commentCount}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppConstants.spacingL),

                // Share button
                InkWell(
                  onTap: () => cardController.shareCard(card.id),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share_outlined,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '${card.shareCount}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // More options
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Show options menu
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
