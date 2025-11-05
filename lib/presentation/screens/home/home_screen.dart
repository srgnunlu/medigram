import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';
import 'package:medigram/presentation/controllers/medical_card_controller.dart';
import 'package:medigram/presentation/controllers/category_controller.dart';
import 'package:medigram/presentation/widgets/cards/medical_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final cardController = Get.find<MedicalCardController>();
      cardController.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final cardController = Get.find<MedicalCardController>();
    final categoryController = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 60,
            child: Obx(
              () => categoryController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingS,
                      ),
                      itemCount: categoryController.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // All categories chip
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppConstants.spacingS,
                            ),
                            child: Obx(
                              () => FilterChip(
                                label: const Text('Tümü'),
                                selected:
                                    cardController.selectedCategory.isEmpty,
                                onSelected: (_) => cardController.clearFilter(),
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        final category = categoryController.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: AppConstants.spacingS,
                          ),
                          child: Obx(
                            () => FilterChip(
                              label: Text(category.name),
                              selected: cardController.selectedCategory ==
                                  category.name,
                              onSelected: (_) =>
                                  cardController.filterByCategory(category.name),
                              backgroundColor: AppColors.surface,
                              selectedColor: category.colorValue,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Medical Cards Feed
          Expanded(
            child: Obx(
              () {
                if (cardController.isLoading &&
                    cardController.medicalCards.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (cardController.medicalCards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_information_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        Text(
                          'Henüz içerik yok',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => cardController.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingS,
                    ),
                    itemCount: cardController.medicalCards.length +
                        (cardController.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == cardController.medicalCards.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.spacingM),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final card = cardController.medicalCards[index];
                      return MedicalCardWidget(card: card);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
