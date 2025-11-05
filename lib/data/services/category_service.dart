import 'package:dio/dio.dart';
import 'package:medigram/data/models/category.dart';
import 'package:medigram/data/models/api_response.dart';
import 'package:medigram/data/services/api_client.dart';
import 'package:medigram/lib/config/app_config.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  // Get all categories
  Future<List<Category>> getCategories({bool activeOnly = true}) async {
    try {
      final queryParams = <String, dynamic>{
        'populate': '*',
        'sort[0]': 'order:asc',
      };

      if (activeOnly) {
        queryParams['filters[isActive][\$eq]'] = true;
      }

      final response = await _apiClient.get(
        AppConfig.instance.categoriesPath,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<List<Category>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => Category.fromJson(item)).toList();
          }
          return <Category>[];
        },
      );

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get single category by ID
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.instance.categoriesPath}/$id',
        queryParameters: {'populate': '*'},
      );

      final apiResponse = ApiResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json),
      );

      if (apiResponse.data == null) {
        throw 'Category not found';
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final response = await _apiClient.get(
        AppConfig.instance.categoriesPath,
        queryParameters: {
          'filters[name][\$eq]': name,
          'populate': '*',
        },
      );

      final apiResponse = ApiResponse<List<Category>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => Category.fromJson(item)).toList();
          }
          return <Category>[];
        },
      );

      final categories = apiResponse.data ?? [];
      return categories.isNotEmpty ? categories.first : null;
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
