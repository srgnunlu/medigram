import 'package:dio/dio.dart';
import 'package:medigram/data/models/medical_card.dart';
import 'package:medigram/data/services/api_client.dart';

class SavedCardService {
  final ApiClient _apiClient = ApiClient();

  // Save a card
  Future<void> saveCard(int medicalCardId) async {
    try {
      await _apiClient.post(
        '/saved-cards',
        data: {'medicalCardId': medicalCardId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Unsave a card
  Future<void> unsaveCard(int medicalCardId) async {
    try {
      await _apiClient.delete('/saved-cards/$medicalCardId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my saved cards
  Future<List<MedicalCard>> getMySavedCards({
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      final response = await _apiClient.get(
        '/saved-cards/my',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((item) {
                final cardData = item['medicalCard'];
                if (cardData != null) {
                  return MedicalCard.fromJson(cardData);
                }
                return null;
              })
              .whereType<MedicalCard>()
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check if card is saved
  Future<bool> checkSaved(int cardId) async {
    try {
      final response = await _apiClient.get('/saved-cards/check/$cardId');

      if (response.data['success'] == true) {
        return response.data['data']['isSaved'] ?? false;
      }

      return false;
    } on DioException catch (e) {
      return false;
    }
  }

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
    return 'An unexpected error occurred. Please try again.';
  }
}
