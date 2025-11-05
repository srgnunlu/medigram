import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final int id;
  final String? iyzicoSubscriptionId;
  final String? iyzicoPaymentId;
  final String status;
  final String plan;
  final double amount;
  final String currency;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  const Subscription({
    required this.id,
    this.iyzicoSubscriptionId,
    this.iyzicoPaymentId,
    required this.status,
    required this.plan,
    required this.amount,
    required this.currency,
    this.startDate,
    this.endDate,
    required this.autoRenew,
    this.cancelledAt,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final data = json['attributes'] ?? json;

    return Subscription(
      id: json['id'] ?? 0,
      iyzicoSubscriptionId: data['iyzicoSubscriptionId'],
      iyzicoPaymentId: data['iyzicoPaymentId'],
      status: data['status'] ?? 'pending',
      plan: data['plan'] ?? 'monthly',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      autoRenew: data['autoRenew'] ?? true,
      cancelledAt: data['cancelledAt'] != null ? DateTime.parse(data['cancelledAt']) : null,
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iyzicoSubscriptionId': iyzicoSubscriptionId,
      'iyzicoPaymentId': iyzicoPaymentId,
      'status': status,
      'plan': plan,
      'amount': amount,
      'currency': currency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'autoRenew': autoRenew,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active' && endDate != null && endDate!.isAfter(DateTime.now());

  int get daysRemaining {
    if (endDate == null) return 0;
    final difference = endDate!.difference(DateTime.now());
    return difference.inDays;
  }

  String get planName {
    return plan == 'monthly' ? 'Aylık' : 'Yıllık';
  }

  @override
  List<Object?> get props => [
        id,
        iyzicoSubscriptionId,
        status,
        plan,
        amount,
        startDate,
        endDate,
        autoRenew,
      ];
}
