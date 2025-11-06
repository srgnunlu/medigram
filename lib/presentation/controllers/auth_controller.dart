import 'package:get/get.dart';
import 'package:medigram/data/models/user.dart';
import 'package:medigram/data/services/auth_service.dart';
import 'package:medigram/data/services/storage_service.dart';
import 'package:medigram/core/routes/app_routes.dart';
import 'package:medigram/core/utils/snackbar_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // Observable state
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser.value = user;
          _isAuthenticated.value = true;
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Login
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final authResponse = await _authService.login(
        identifier: identifier,
        password: password,
      );

      _currentUser.value = authResponse.user;
      _isAuthenticated.value = true;

      SnackbarHelper.showSuccess('Giriş başarılı! Hoş geldiniz.');

      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Register
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final authResponse = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      _currentUser.value = authResponse.user;
      _isAuthenticated.value = true;

      SnackbarHelper.showSuccess('Kayıt başarılı! Hoş geldiniz.');

      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();

      _currentUser.value = null;
      _isAuthenticated.value = false;

      SnackbarHelper.showInfo('Çıkış yapıldı.');

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      SnackbarHelper.showError('Çıkış yapılırken bir hata oluştu.');
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      _isLoading.value = true;

      await _authService.forgotPassword(email);

      SnackbarHelper.showSuccess(
        'Şifre sıfırlama linki email adresinize gönderildi.',
      );

      Get.back();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if user is logged in (for splash screen)
  Future<bool> checkAuth() async {
    await _checkAuthStatus();
    return _isAuthenticated.value;
  }
}
