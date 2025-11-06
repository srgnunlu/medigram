import 'package:dio/dio.dart';
import 'package:medigram/data/models/ai_generated_image.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/data/services/api_client.dart';

class AIService {
  final ApiClient _apiClient;

  AIService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Generate medical image using DALL-E
  Future<List<AIGeneratedImage>> generateImage({
    required String prompt,
    String size = '1024x1024',
    int n = 1,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai-service/generate-image',
        data: {
          'prompt': prompt,
          'size': size,
          'n': n,
        },
      );

      final data = response.data['data'];
      final images = (data['images'] as List)
          .map((img) => AIGeneratedImage.fromJson({
                'url': img['url'],
                'revised_prompt': img['revised_prompt'],
                'original_prompt': data['prompt'],
                'created_at': DateTime.now().toIso8601String(),
              }))
          .toList();

      return images;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Premium subscription required for AI features');
      }
      throw Exception('Failed to generate image: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  /// Generate medical content using GPT
  Future<String> generateContent({
    required String topic,
    String? category,
    String tone = 'professional',
    String length = 'medium',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai-service/generate-content',
        data: {
          'topic': topic,
          'category': category,
          'tone': tone,
          'length': length,
        },
      );

      final data = response.data['data'];
      return data['content'] ?? '';
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Premium subscription required for AI features');
      }
      throw Exception('Failed to generate content: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  /// Get personalized content recommendations
  Future<List<MedicalCard>> getRecommendations({
    int limit = 10,
    String? category,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/ai-service/recommendations',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      final data = response.data['data'];
      final recommendations = (data['recommendations'] as List)
          .map((item) => MedicalCard.fromJson(item))
          .toList();

      return recommendations;
    } on DioException catch (e) {
      throw Exception('Failed to get recommendations: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// Analyze image and get medical content suggestions
  Future<String> analyzeImage({required String imageUrl}) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai-service/analyze-image',
        data: {
          'imageUrl': imageUrl,
        },
      );

      final data = response.data['data'];
      return data['analysis'] ?? '';
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Premium subscription required for AI features');
      }
      throw Exception('Failed to analyze image: ${e.message}');
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}
