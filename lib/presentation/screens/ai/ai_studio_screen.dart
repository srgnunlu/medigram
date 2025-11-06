import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/presentation/controllers/ai_controller.dart';
import 'package:medigram/presentation/controllers/premium_controller.dart';
import 'package:medigram/presentation/screens/premium/subscription_screen.dart';

class AIStudioScreen extends StatefulWidget {
  const AIStudioScreen({super.key});

  @override
  State<AIStudioScreen> createState() => _AIStudioScreenState();
}

class _AIStudioScreenState extends State<AIStudioScreen> {
  final aiController = Get.put(AIController());
  final premiumController = Get.put(PremiumController());
  final promptController = TextEditingController();
  final topicController = TextEditingController();

  String selectedFeature = 'image'; // image, content, recommendations

  @override
  void dispose() {
    promptController.dispose();
    topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Studio'),
        actions: [
          Obx(() {
            final isPremium = premiumController.isPremium;
            if (!isPremium) {
              return IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () => Get.to(() => const SubscriptionScreen()),
                tooltip: 'Premium\'a Geç',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final isPremium = premiumController.isPremium;

        if (!isPremium) {
          return _buildPremiumRequired();
        }

        return Column(
          children: [
            // Feature Tabs
            _buildFeatureTabs(),

            // Feature Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: _buildFeatureContent(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPremiumRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),
            Text(
              'AI Studio Premium Özellik',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'AI destekli görsel oluşturma, içerik üretme ve kişiselleştirilmiş öneriler için premium üyelik gereklidir.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const SubscriptionScreen()),
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
    );
  }

  Widget _buildFeatureTabs() {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Görsel',
              icon: Icons.image,
              feature: 'image',
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'İçerik',
              icon: Icons.article,
              feature: 'content',
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Öneriler',
              icon: Icons.recommend,
              feature: 'recommendations',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required String feature,
  }) {
    final isSelected = selectedFeature == feature;

    return InkWell(
      onTap: () => setState(() => selectedFeature = feature),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureContent() {
    switch (selectedFeature) {
      case 'image':
        return _buildImageGeneration();
      case 'content':
        return _buildContentGeneration();
      case 'recommendations':
        return _buildRecommendations();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageGeneration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Görsel Oluşturma',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          'Tıbbi illüstrasyon ve görsel oluşturmak için prompt girin',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingL),

        // Prompt Input
        TextField(
          controller: promptController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Görsel Açıklaması',
            hintText: 'Örn: İnsan kalp anatomi diyagramı, renkli ve detaylı',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.auto_awesome),
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Generate Button
        Obx(() {
          final isLoading = aiController.isGeneratingImage.value;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      if (promptController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Hata',
                          'Lütfen bir görsel açıklaması girin',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      aiController.generateImage(prompt: promptController.text);
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isLoading ? 'Oluşturuluyor...' : 'Görsel Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.all(AppConstants.spacingM),
              ),
            ),
          );
        }),

        const SizedBox(height: AppConstants.spacingXL),

        // Generated Images
        Obx(() {
          final images = aiController.generatedImages;
          if (images.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oluşturulan Görseller',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingM),
              ...images.map((img) => Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        img.url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 300,
                            color: AppColors.surfaceLight,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildContentGeneration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI İçerik Oluşturma',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          'Tıbbi içerik oluşturmak için bir konu girin',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingL),

        // Topic Input
        TextField(
          controller: topicController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'İçerik Konusu',
            hintText: 'Örn: Kalp krizi belirtileri ve ilk yardım',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.lightbulb),
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Generate Button
        Obx(() {
          final isLoading = aiController.isGeneratingContent.value;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      if (topicController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Hata',
                          'Lütfen bir konu girin',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      aiController.generateContent(
                        topic: topicController.text,
                        tone: 'professional',
                        length: 'medium',
                      );
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isLoading ? 'Oluşturuluyor...' : 'İçerik Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.all(AppConstants.spacingM),
              ),
            ),
          );
        }),

        const SizedBox(height: AppConstants.spacingXL),

        // Generated Content
        Obx(() {
          final content = aiController.generatedContent.value;
          if (content.isEmpty) {
            return const SizedBox.shrink();
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Oluşturulan İçerik',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Copy to clipboard
                          Get.snackbar(
                            'Başarılı',
                            'İçerik kopyalandı',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişiselleştirilmiş Öneriler',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          'Size özel içerik önerileri',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingL),

        // Load Button
        Obx(() {
          final isLoading = aiController.isLoadingRecommendations.value;
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => aiController.loadRecommendations(limit: 10),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.recommend),
              label: Text(isLoading ? 'Yükleniyor...' : 'Önerileri Yükle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.all(AppConstants.spacingM),
              ),
            ),
          );
        }),

        const SizedBox(height: AppConstants.spacingL),

        // Recommendations List
        Obx(() {
          final recommendations = aiController.recommendations;
          if (recommendations.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${recommendations.length} Öneri Bulundu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingM),
              ...recommendations.map((card) => Card(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.getCategoryColor(card.category),
                        child: Icon(
                          Icons.medical_information,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      title: Text(card.title),
                      subtitle: Text(
                        card.category,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to card detail
                      },
                    ),
                  )),
            ],
          );
        }),
      ],
    );
  }
}
