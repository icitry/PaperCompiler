import 'dart:ui';

import 'package:app/src/services/user_management_system.dart';
import 'package:go_router/go_router.dart';

import '../pages/main_page.dart';
import '../pages/register_page.dart';

class Routes {
  static const main = '/';
  static const register = '/register';
}

class RoutingService {
  static GoRouter getRouter(
    String mainPageBgImage,
    String registerPageBgImage,
    Color themeColor,
  ) {
    return GoRouter(
      initialLocation: Routes.register,
      redirect: (context, state) {
        String currentPath = state.uri.toString();
        bool isRegisterPage = currentPath == Routes.register;
        bool isUserRegistered = UserManagementSystem.isRegistered();
        if (isRegisterPage && isUserRegistered) return Routes.main;
        if (!isUserRegistered && !isRegisterPage) return Routes.register;
        return null;
      },
      routes: [
        GoRoute(
          path: Routes.main,
          builder: (context, state) => MainPage(
            themeColor: themeColor,
            bgImagePath: mainPageBgImage,
          ),
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) => RegisterPage(
            themeColor: themeColor,
            bgImagePath: registerPageBgImage,
          ),
        ),
      ],
    );
  }
}
