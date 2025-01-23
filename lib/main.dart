import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/Comman/SplashScreen.dart';
import 'package:splitwise/View/User/ChangePasswordScreen.dart';
import 'package:splitwise/View/Group/GroupListScreen.dart';

import 'package:splitwise/View/HomeScreen.dart';
import 'package:splitwise/View/User/LoginScreen.dart';
import 'package:splitwise/View/User/ProfileEditScreen.dart';
import 'package:splitwise/View/User/RegisterScreen.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize controllers
  final ThemeController themeController = Get.put(ThemeController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
          title: 'Payment App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: AppColors.lightPrimaryColor,
            scaffoldBackgroundColor: AppColors.lightBackgroundColor,
            colorScheme: ColorScheme.light(
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
                borderSide: BorderSide(color: AppColors.lightPrimaryColor),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.darkPrimaryColor,
            scaffoldBackgroundColor: AppColors.darkBackgroundColor,
            colorScheme: ColorScheme.dark(
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
                borderSide: BorderSide(color: AppColors.darkPrimaryColor),
              ),
            ),
          ),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,

          // Initial Route
          initialRoute: '/splash',

          // Custom Transition
          defaultTransition: Transition.fadeIn,
          transitionDuration: Duration(milliseconds: 300),

          // Route Management
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
            // GetPage(
            //   name: '/groupScreen',
            //   page: () => GroupScreen(isUpdate: false,),
            //   transition: Transition.rightToLeft,
            // ),
            GetPage(
              name: '/groupScreenList',
              page: () => GroupListScreen(),
              transition: Transition.rightToLeft,
            ),
          ],
        ));
  }
}
