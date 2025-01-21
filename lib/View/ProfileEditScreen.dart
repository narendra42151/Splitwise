import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/AnimationWidget.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

class ProfileEditScreen extends StatelessWidget {
  final AuthController controller = Get.find();
  final ThemeController themeController = Get.find();
  final TextEditingController usernameController;
  final RxString selectedImagePath = ''.obs;

  ProfileEditScreen() : usernameController = TextEditingController() {
    // Initialize with current user data??
    if (controller.user.value != null) {
      usernameController.text = "";
      selectedImagePath.value = "";
    }
  }

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
            appBar: AppBar(
              title: FadeSlideTransition(
                child: Text('Edit Profile'),
              ),
              actions: [
                AnimatedSwitcher(
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
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture
                    FadeSlideTransition(
                      delay: 0.2,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Implement image picker
                          },
                          child: Hero(
                            tag: 'profilePic',
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                image: selectedImagePath.value.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            selectedImagePath.value),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: selectedImagePath.value.isEmpty
                                  ? Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Username Field
                    FadeSlideTransition(
                      delay: 0.4,
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    FadeSlideTransition(
                      delay: 0.6,
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
                                  : () => controller.updateUserDetails(
                                        usernameController.text,
                                        selectedImagePath.value,
                                      ),
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
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 24),
                    // Change Password Button
                    FadeSlideTransition(
                      delay: 0.8,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to change password screen
                          Get.toNamed('/updatePassword');
                        },
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
