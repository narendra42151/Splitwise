import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/AnimationWidget.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  final ThemeController themeController = Get.put(ThemeController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedTheme(
          data: themeController.isDarkMode.value
              ? ThemeData.dark().copyWith(
                  primaryColor: AppColors.darkPrimaryColor,
                  scaffoldBackgroundColor: AppColors.darkBackgroundColor,
                )
              : ThemeData.light().copyWith(
                  primaryColor: AppColors.lightPrimaryColor,
                  scaffoldBackgroundColor: AppColors.lightBackgroundColor,
                ),
          duration: Duration(milliseconds: 500),
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme Toggle Button
                    Align(
                      alignment: Alignment.topRight,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return RotationTransition(
                            turns: animation,
                            child: child,
                          );
                        },
                        child: IconButton(
                          key: ValueKey<bool>(themeController.isDarkMode.value),
                          icon: Icon(
                            themeController.isDarkMode.value
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: themeController.toggleTheme,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Animated Logo
                    FadeSlideTransition(
                      delay: 0,
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 1000),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: value * 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.payment,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Welcome Text with Animation
                    FadeSlideTransition(
                      delay: 0.2,
                      child: Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Phone Number Field with Animation
                    FadeSlideTransition(
                      delay: 0.4,
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field with Animation
                    FadeSlideTransition(
                      delay: 0.6,
                      child: Obx(() => TextField(
                            controller: passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    key: ValueKey<bool>(
                                        controller.isPasswordVisible.value),
                                  ),
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 24),
                    // Login Button with Animation
                    FadeSlideTransition(
                      delay: 0.8,
                      child: Obx(() => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  blurRadius:
                                      controller.isLoading.value ? 0 : 10,
                                  spreadRadius:
                                      controller.isLoading.value ? 0 : 1,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.login(phoneController.text,
                                      passwordController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 200),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 16),
                    // Register Link with Animation
                    FadeSlideTransition(
                      delay: 1.0,
                      child: TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: Text(
                          'Don\'t have an account? Register',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Error Message with Animation
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
