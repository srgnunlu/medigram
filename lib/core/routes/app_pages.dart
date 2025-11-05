import 'package:get/get.dart';
import 'package:medigram/core/routes/app_routes.dart';
import 'package:medigram/presentation/screens/splash/splash_screen.dart';
import 'package:medigram/presentation/screens/auth/login_screen.dart';
import 'package:medigram/presentation/screens/auth/register_screen.dart';
import 'package:medigram/presentation/screens/home/home_screen.dart';
import 'package:medigram/presentation/controllers/auth_controller.dart';
import 'package:medigram/presentation/controllers/medical_card_controller.dart';
import 'package:medigram/presentation/controllers/category_controller.dart';

class AppPages {
  AppPages._();

  static final pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      transition: Transition.fadeIn,
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      bindings: [
        BindingsBuilder(() {
          Get.lazyPut(() => AuthController());
          Get.lazyPut(() => MedicalCardController());
          Get.lazyPut(() => CategoryController());
        }),
      ],
      transition: Transition.fadeIn,
    ),
  ];
}
