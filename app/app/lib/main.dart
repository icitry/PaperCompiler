import 'package:app/src/services/compile_service.dart';
import 'package:app/src/services/routing_service.dart';
import 'package:app/src/services/user_management_system.dart';
import 'package:flutter/material.dart';

class Constants {
  static const rootApiUrl = "http://10.0.2.2:8000";
  static const assetImagesPathRoot = 'assets/images/';

  static const Color themeColor = Color.fromARGB(194, 131, 63, 203);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UserManagementSystem.rootApiUrl = Constants.rootApiUrl;
  await UserManagementSystem.init();

  CompileService.rootApiUrl = Constants.rootApiUrl;

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final _router = RoutingService.getRouter(
    '${Constants.assetImagesPathRoot}main_page_bg.jpg',
    '${Constants.assetImagesPathRoot}register_page_bg.jpg',
    Constants.themeColor,
  );

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
