import 'package:get/get.dart';
import 'package:medigram/data/models/ai_generated_image.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/data/services/ai_service.dart';

class AIController extends GetxController {
  final AIService _aiService = AIService();

  // Image Generation
  final RxBool isGeneratingImage = false.obs;
  final RxList<AIGeneratedImage> generatedImages = <AIGeneratedImage>[].obs;
  final RxString imageGenerationError = ''.obs;

  // Content Generation
  final RxBool isGeneratingContent = false.obs;
  final RxString generatedContent = ''.obs;
  final RxString contentGenerationError = ''.obs;

  // Recommendations
  final RxBool isLoadingRecommendations = false.obs;
  final RxList<MedicalCard> recommendations = <MedicalCard>[].obs;
  final RxString recommendationsError = ''.obs;

  // Image Analysis
  final RxBool isAnalyzingImage = false.obs;
  final RxString imageAnalysis = ''.obs;
  final RxString imageAnalysisError = ''.obs;

  /// Generate medical illustration image
  Future<void> generateImage({
    required String prompt,
    String size = '1024x1024',
  }) async {
    try {
      isGeneratingImage.value = true;
      imageGenerationError.value = '';

      final images = await _aiService.generateImage(
        prompt: prompt,
        size: size,
        n: 1,
      );

      generatedImages.addAll(images);

      Get.snackbar(
        'Başarılı',
        'Görsel başarıyla oluşturuldu!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      imageGenerationError.value = e.toString();
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingImage.value = false;
    }
  }

  /// Generate medical content
  Future<void> generateContent({
    required String topic,
    String? category,
    String tone = 'professional',
    String length = 'medium',
  }) async {
    try {
      isGeneratingContent.value = true;
      contentGenerationError.value = '';
      generatedContent.value = '';

      final content = await _aiService.generateContent(
        topic: topic,
        category: category,
        tone: tone,
        length: length,
      );

      generatedContent.value = content;

      Get.snackbar(
        'Başarılı',
        'İçerik başarıyla oluşturuldu!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      contentGenerationError.value = e.toString();
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingContent.value = false;
    }
  }

  /// Load personalized recommendations
  Future<void> loadRecommendations({
    int limit = 10,
    String? category,
  }) async {
    try {
      isLoadingRecommendations.value = true;
      recommendationsError.value = '';

      final results = await _aiService.getRecommendations(
        limit: limit,
        category: category,
      );

      recommendations.value = results;
    } catch (e) {
      recommendationsError.value = e.toString();
      Get.snackbar(
        'Hata',
        'Öneriler yüklenemedi: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  /// Analyze medical image
  Future<void> analyzeImage({required String imageUrl}) async {
    try {
      isAnalyzingImage.value = true;
      imageAnalysisError.value = '';
      imageAnalysis.value = '';

      final analysis = await _aiService.analyzeImage(imageUrl: imageUrl);
      imageAnalysis.value = analysis;

      Get.snackbar(
        'Başarılı',
        'Görsel analiz edildi!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      imageAnalysisError.value = e.toString();
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAnalyzingImage.value = false;
    }
  }

  /// Clear generated images
  void clearGeneratedImages() {
    generatedImages.clear();
    imageGenerationError.value = '';
  }

  /// Clear generated content
  void clearGeneratedContent() {
    generatedContent.value = '';
    contentGenerationError.value = '';
  }

  /// Clear image analysis
  void clearImageAnalysis() {
    imageAnalysis.value = '';
    imageAnalysisError.value = '';
  }
}
