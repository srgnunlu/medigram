import 'package:dio/dio.dart';
import 'package:medigram/data/models/subscription.dart';
import 'package:medigram/data/services/api_client.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  // Create checkout session
  Future<Map<String, dynamic>> createCheckout(String plan) async {
    try {
      final response = await _apiClient.post(
        '/subscriptions/checkout',
        data: {'plan': plan},
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }

      throw response.data['message'] ?? 'Failed to create checkout';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my subscription
  Future<Subscription?> getMySubscription() async {
    try {
      final response = await _apiClient.get('/subscriptions/my');

      if (response.data['success'] == true && response.data['data'] != null) {
        return Subscription.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      await _apiClient.post('/subscriptions/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check premium status
  Future<Map<String, dynamic>> checkPremium() async {
    try {
      final response = await _apiClient.get('/subscriptions/check-premium');

      if (response.data['success'] == true) {
        return response.data['data'];
      }

      return {'isPremium': false, 'subscription': null};
    } on DioException catch (e) {
      return {'isPremium': false, 'subscription': null};
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
