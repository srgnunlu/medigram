import 'package:dio/dio.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/data/models/api_response.dart';
import 'package:medigram/data/services/api_client.dart';
import 'package:medigram/lib/config/app_config.dart';

class MedicalCardService {
  final ApiClient _apiClient = ApiClient();

  // Get all medical cards with optional filters
  Future<List<MedicalCard>> getMedicalCards({
    String? category,
    bool? isPremium,
    String? search,
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pagination[page]': page,
        'pagination[pageSize]': pageSize,
        'populate': '*',
        'sort[0]': 'createdAt:desc',
      };

      if (category != null && category.isNotEmpty) {
        queryParams['filters[category][\$eq]'] = category;
      }

      if (isPremium != null) {
        queryParams['filters[isPremium][\$eq]'] = isPremium;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['filters[\$or][0][title][\$containsi]'] = search;
        queryParams['filters[\$or][1][content][\$containsi]'] = search;
        queryParams['filters[\$or][2][author][\$containsi]'] = search;
      }

      final response = await _apiClient.get(
        AppConfig.instance.medicalCardsPath,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<List<MedicalCard>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => MedicalCard.fromJson(item)).toList();
          }
          return <MedicalCard>[];
        },
      );

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get single medical card by ID
  Future<MedicalCard> getMedicalCardById(int id) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.instance.medicalCardsPath}/$id',
        queryParameters: {'populate': '*'},
      );

      final apiResponse = ApiResponse<MedicalCard>.fromJson(
        response.data,
        (json) => MedicalCard.fromJson(json),
      );

      if (apiResponse.data == null) {
        throw 'Medical card not found';
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Like/Unlike a medical card
  Future<Map<String, dynamic>> toggleLike(int cardId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.instance.medicalCardsPath}/$cardId/like',
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        return {
          'isLiked': data['isLiked'] ?? false,
          'likeCount': data['likeCount'] ?? 0,
        };
      }

      throw 'Invalid response format';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Share a medical card (increment share count)
  Future<int> shareMedicalCard(int cardId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.instance.medicalCardsPath}/$cardId/share',
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        return data['shareCount'] ?? 0;
      }

      throw 'Invalid response format';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search medical cards
  Future<List<MedicalCard>> searchMedicalCards(String query) async {
    return getMedicalCards(search: query);
  }

  // Get trending medical cards (most liked/shared)
  Future<List<MedicalCard>> getTrendingCards({int limit = 10}) async {
    try {
      final queryParams = <String, dynamic>{
        'pagination[pageSize]': limit,
        'populate': '*',
        // You can implement sorting by likes/shares when backend supports it
        'sort[0]': 'createdAt:desc',
      };

      final response = await _apiClient.get(
        AppConfig.instance.medicalCardsPath,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<List<MedicalCard>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => MedicalCard.fromJson(item)).toList();
          }
          return <MedicalCard>[];
        },
      );

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final errorData = data['error'];
          if (errorData is Map && errorData.containsKey('message')) {
            return errorData['message'].toString();
          }
          return errorData.toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return 'An error occurred: ${error.response!.statusCode}';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
