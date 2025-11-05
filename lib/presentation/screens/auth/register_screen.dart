import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/core/utils/validators.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();
      authController.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacingL),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 40,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Title
                Text(
                  'Hesap Oluştur',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingS),

                Text(
                  'Medigram\'a katılın',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'kullanici_adi',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'ornek@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Password field
                Obx(
                  () => TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            _obscurePassword.value = !_obscurePassword.value,
                      ),
                      hintText: 'En az 6 karakter',
                    ),
                    obscureText: _obscurePassword.value,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Confirm password field
                Obx(
                  () => TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Şifre Tekrar',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => _obscureConfirmPassword.value =
                            !_obscureConfirmPassword.value,
                      ),
                    ),
                    obscureText: _obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRegister(),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Register button
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        authController.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: authController.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimary,
                              ),
                            ),
                          )
                        : const Text('Kayıt Ol'),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Terms and conditions
                Text(
                  'Kayıt olarak Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabınız var mı? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Giriş Yapın'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
