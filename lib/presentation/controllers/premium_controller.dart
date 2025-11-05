import 'package:get/get.dart';
import 'package:medigram/data/models/subscription.dart';
import 'package:medigram/data/services/subscription_service.dart';
import 'package:medigram/data/services/auth_service.dart';
import 'package:medigram/core/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumController extends GetxController {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AuthService _authService = AuthService();

  final Rx<Subscription?> _subscription = Rx<Subscription?>(null);
  final RxBool _isPremium = false.obs;
  final RxBool _isLoading = false.obs;

  Subscription? get subscription => _subscription.value;
  bool get isPremium => _isPremium.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkPremiumStatus();
  }

  // Check premium status
  Future<void> checkPremiumStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        _isPremium.value = false;
        return;
      }

      final result = await _subscriptionService.checkPremium();
      _isPremium.value = result['isPremium'] ?? false;

      if (result['subscription'] != null) {
        _subscription.value = Subscription.fromJson(result['subscription']);
      }
    } catch (e) {
      _isPremium.value = false;
    }
  }

  // Get subscription details
  Future<void> fetchSubscription() async {
    try {
      _isLoading.value = true;
      final sub = await _subscriptionService.getMySubscription();
      _subscription.value = sub;
      _isPremium.value = sub?.isActive ?? false;
    } catch (e) {
      SnackbarHelper.showError('Abonelik bilgileri alınamadı: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Start checkout
  Future<void> startCheckout(String plan) async {
    try {
      _isLoading.value = true;

      final checkoutData = await _subscriptionService.createCheckout(plan);
      final checkoutUrl = checkoutData['checkoutUrl'];

      if (checkoutUrl != null) {
        // Launch checkout URL
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          SnackbarHelper.showInfo(
            'Ödeme sayfası açıldı. İşlem tamamlandıktan sonra uygulamaya geri dönün.',
          );

          // Refresh subscription after a delay
          Future.delayed(const Duration(seconds: 5), () {
            fetchSubscription();
          });
        } else {
          throw 'Ödeme sayfası açılamadı';
        }
      }
    } catch (e) {
      SnackbarHelper.showError('Ödeme başlatılamadı: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      _isLoading.value = true;

      await _subscriptionService.cancelSubscription();

      _subscription.value = null;
      _isPremium.value = false;

      SnackbarHelper.showSuccess('Abonelik iptal edildi');
    } catch (e) {
      SnackbarHelper.showError('Abonelik iptal edilemedi: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if user can access premium content
  bool canAccessPremiumContent() {
    return _isPremium.value;
  }

  // Get plan price
  static double getPlanPrice(String plan) {
    return plan == 'monthly' ? 29.99 : 299.99;
  }

  // Get plan name
  static String getPlanName(String plan) {
    return plan == 'monthly' ? 'Aylık' : 'Yıllık';
  }
}
