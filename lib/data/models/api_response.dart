import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final T? data;
  final Meta? meta;
  final String? error;

  const ApiResponse({
    this.data,
    this.meta,
    this.error,
  });

  bool get isSuccess => error == null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Handle Strapi v4 response format
    if (json.containsKey('data')) {
      final data = json['data'];
      T? parsedData;

      if (data != null && fromJsonT != null) {
        if (data is List) {
          parsedData = data.map((item) => fromJsonT(item)).toList() as T;
        } else {
          parsedData = fromJsonT(data);
        }
      }

      return ApiResponse(
        data: parsedData,
        meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      );
    }

    // Handle error response
    if (json.containsKey('error')) {
      final error = json['error'];
      return ApiResponse(
        error: error is String ? error : error['message'] ?? 'Unknown error',
      );
    }

    // Handle direct data (custom endpoints)
    if (fromJsonT != null) {
      return ApiResponse(data: fromJsonT(json));
    }

    return ApiResponse(data: json as T?);
  }

  @override
  List<Object?> get props => [data, meta, error];
}

class Meta extends Equatable {
  final Pagination? pagination;

  const Meta({this.pagination});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination?.toJson(),
    };
  }

  @override
  List<Object?> get props => [pagination];
}

class Pagination extends Equatable {
  final int page;
  final int pageSize;
  final int pageCount;
  final int total;

  const Pagination({
    required this.page,
    required this.pageSize,
    required this.pageCount,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 25,
      pageCount: json['pageCount'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'pageCount': pageCount,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [page, pageSize, pageCount, total];
}
