import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/Comman/ServerDownScreen.dart';
import 'package:splitwise/Comman/SplashScreen.dart';
import 'package:splitwise/View/User/ChangePasswordScreen.dart';
import 'package:splitwise/View/Group/GroupListScreen.dart';
import 'package:splitwise/View/HomeScreen.dart';
import 'package:splitwise/View/User/LoginScreen.dart';
import 'package:splitwise/View/User/ProfileEditScreen.dart';
import 'package:splitwise/View/User/RegisterScreen.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'Payment App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: AppColors.lightPrimaryColor,
          scaffoldBackgroundColor: AppColors.lightBackgroundColor,
          colorScheme: const ColorScheme.light(
            primary: AppColors.lightPrimaryColor,
            secondary: AppColors.lightSecondaryColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightPrimaryColor),
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: AppColors.darkPrimaryColor,
          scaffoldBackgroundColor: AppColors.darkBackgroundColor,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.darkPrimaryColor,
            secondary: AppColors.darkSecondaryColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkPrimaryColor),
            ),
          ),
        ),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/splash',
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        getPages: [
          GetPage(
            name: '/splash',
            page: () => SplashScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/login',
            page: () => LoginScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/register',
            page: () => RegisterScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/internet-exception',
            page: () => const ServerDownScreen(
              isLogin: false,
              server: false,
            ),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/server-exception',
            page: () => const ServerDownScreen(
              isLogin: false,
              server: true,
            ),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/home',
            page: () => HomeScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/profile/edit',
            page: () => ProfileEditScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/updatePassword',
            page: () => ChangePasswordScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/groupScreenList',
            page: () => GroupListScreen(),
            transition: Transition.rightToLeft,
          ),
        ],
      );
    });
  }
}
