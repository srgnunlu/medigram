import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';
import 'package:medigram/core/constants/app_constants.dart';
import 'package:medigram/core/routes/app_routes.dart';
import 'package:medigram/core/utils/validators.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();
      authController.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacingXL * 2),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 50,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Welcome text
                Text(
                  'Hoş Geldiniz',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingS),

                Text(
                  'Hesabınıza giriş yapın',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL * 2),

                // Email/Username field
                TextFormField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'Email veya Kullanıcı Adı',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.required(value, 'Email veya kullanıcı adı'),
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
                    ),
                    obscureText: _obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    validator: Validators.password,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Login button
                Obx(
                  () => ElevatedButton(
                    onPressed: authController.isLoading ? null : _handleLogin,
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
                        : const Text('Giriş Yap'),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: const Text('Kayıt Olun'),
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
