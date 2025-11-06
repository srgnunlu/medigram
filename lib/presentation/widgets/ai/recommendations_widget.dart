import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/presentation/controllers/ai_controller.dart';
import 'package:medigram/presentation/screens/card/card_detail_screen.dart';
import 'package:medigram/presentation/screens/ai/ai_studio_screen.dart';

class RecommendationsWidget extends StatefulWidget {
  const RecommendationsWidget({super.key});

  @override
  State<RecommendationsWidget> createState() => _RecommendationsWidgetState();
}

class _RecommendationsWidgetState extends State<RecommendationsWidget> {
  final aiController = Get.put(AIController());

  @override
  void initState() {
    super.initState();
    // Load recommendations on init
    Future.delayed(Duration.zero, () {
      aiController.loadRecommendations(limit: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recommendations = aiController.recommendations;
      final isLoading = aiController.isLoadingRecommendations.value;

      if (isLoading && recommendations.isEmpty) {
        return const SizedBox.shrink();
      }

      if (recommendations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size Özel Öneriler',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'AI destekli kişiselleştirilmiş içerikler',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const AIStudioScreen()),
                  child: const Text('Tümü'),
                ),
              ],
            ),
          ),

          // Horizontal scrollable list
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
              ),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final card = recommendations[index];
                return GestureDetector(
                  onTap: () => Get.to(() => CardDetailScreen(card: card)),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: AppConstants.spacingM),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Background gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.getCategoryColor(card.category)
                                      .withOpacity(0.3),
                                  AppColors.surface,
                                ],
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category chip
                                Chip(
                                  label: Text(
                                    card.category,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor:
                                      AppColors.getCategoryColor(card.category),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Spacer(),

                                // Title
                                Text(
                                  card.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppConstants.spacingS),

                                // Content preview
                                Text(
                                  card.content,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppConstants.spacingS),

                                // Stats
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${card.likes.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(width: AppConstants.spacingM),
                                    Icon(
                                      Icons.comment,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${card.commentCount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // AI badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI Öneri',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),
        ],
      );
    });
  }
}
