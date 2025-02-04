// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:splitwise/Comman/AnimationWidget.dart';
// import 'package:splitwise/Comman/Colors.dart';
// import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';
// import 'package:splitwise/Utils/PhoneAuth/VerifyPhone.dart';

// class RegisterScreen extends StatelessWidget {
//   final AuthController controller = Get.find();
//   final ThemeController themeController = Get.find();
//   final VerifyPhone verifyPhoneController = Get.put(VerifyPhone());
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController upiIdController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final RxString selectedImagePath = ''.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => AnimatedTheme(
//           data: themeController.isDarkMode.value
//               ? ThemeData.dark().copyWith(
//                   primaryColor: AppColors.darkPrimaryColor,
//                   scaffoldBackgroundColor: AppColors.darkBackgroundColor,
//                 )
//               : ThemeData.light().copyWith(
//                   primaryColor: AppColors.lightPrimaryColor,
//                   scaffoldBackgroundColor: AppColors.lightBackgroundColor,
//                 ),
//           duration: Duration(milliseconds: 500),
//           child: Scaffold(
//             appBar: AppBar(
//               title: FadeSlideTransition(
//                 child: Text('Register'),
//               ),
//               actions: [
//                 AnimatedSwitcher(
//                   duration: Duration(milliseconds: 300),
//                   transitionBuilder:
//                       (Widget child, Animation<double> animation) {
//                     return RotationTransition(
//                       turns: animation,
//                       child: child,
//                     );
//                   },
//                   child: IconButton(
//                     key: ValueKey<bool>(themeController.isDarkMode.value),
//                     icon: Icon(
//                       themeController.isDarkMode.value
//                           ? Icons.light_mode
//                           : Icons.dark_mode,
//                     ),
//                     onPressed: themeController.toggleTheme,
//                   ),
//                 ),
//               ],
//             ),
//             body: SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Profile Picture Selection
//                     FadeSlideTransition(
//                       delay: 0.2,
//                       child: Center(
//                         child: GestureDetector(
//                           onTap: () {
//                             // Implement image picker
//                           },
//                           child: TweenAnimationBuilder(
//                             tween: Tween<double>(begin: 0, end: 1),
//                             duration: Duration(milliseconds: 800),
//                             builder: (context, double value, child) {
//                               return Transform.scale(
//                                 scale: value,
//                                 child: Container(
//                                   height: 120,
//                                   width: 120,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Theme.of(context)
//                                         .primaryColor
//                                         .withOpacity(0.1),
//                                     border: Border.all(
//                                       color: Theme.of(context).primaryColor,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: Icon(
//                                     Icons.camera_alt,
//                                     size: 40,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     // Username Field
//                     FadeSlideTransition(
//                       delay: 0.4,
//                       child: TextField(
//                         controller: usernameController,
//                         decoration: InputDecoration(
//                           labelText: 'Username',
//                           prefixIcon: const Icon(Icons.person),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Phone Field
//                     FadeSlideTransition(
//                       delay: 0.6,
//                       child: TextField(
//                         controller: phoneController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           labelText: 'Phone Number',
//                           prefixText: '+91 ',
//                           prefixIcon: const Icon(Icons.phone),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     FadeSlideTransition(
//                         delay: 0.4,
//                         child: TextField(
//                           controller:
//                               upiIdController, // Your existing controller

//                           decoration: InputDecoration(
//                             labelText: 'UPI ID',
//                             prefixIcon:
//                                 const Icon(Icons.account_balance_wallet),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         )),

//                     const SizedBox(height: 16),
//                     // Password Field
//                     FadeSlideTransition(
//                       delay: 0.8,
//                       child: Obx(() => TextField(
//                             controller: passwordController,
//                             obscureText: !controller.isPasswordVisible.value,
//                             decoration: InputDecoration(
//                               labelText: 'Password',
//                               prefixIcon: const Icon(Icons.lock),
//                               suffixIcon: IconButton(
//                                 icon: AnimatedSwitcher(
//                                   duration: Duration(milliseconds: 200),
//                                   child: Icon(
//                                     controller.isPasswordVisible.value
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                     key: ValueKey<bool>(
//                                         controller.isPasswordVisible.value),
//                                   ),
//                                 ),
//                                 onPressed: controller.togglePasswordVisibility,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           )),
//                     ),
//                     const SizedBox(height: 16),
//                     // OTP Field
//                     Obx(() {
//                       if (verifyPhoneController.isOtpSent.value) {
//                         return FadeSlideTransition(
//                           delay: 1.0,
//                           child: TextField(
//                             controller: otpController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: 'OTP',
//                               prefixIcon: const Icon(Icons.lock),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         return SizedBox.shrink();
//                       }
//                     }),
//                     const SizedBox(height: 32),
//                     // Register Button
//                     FadeSlideTransition(
//                       delay: 1.0,
//                       child: Obx(() => AnimatedContainer(
//                             duration: Duration(milliseconds: 300),
//                             height: 56,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.3),
//                                   blurRadius:
//                                       controller.isLoading.value ? 0 : 10,
//                                   spreadRadius:
//                                       controller.isLoading.value ? 0 : 1,
//                                 ),
//                               ],
//                             ),
//                             child: ElevatedButton(
//                               onPressed: controller.isLoading.value
//                                   ? null
//                                   : () async {
//                                       if (verifyPhoneController
//                                           .isOtpSent.value) {
//                                         // Verify OTP
//                                         bool isVerified =
//                                             await verifyPhoneController
//                                                 .signInWithPhoneNumber(
//                                                     otpController.text);
//                                         if (isVerified) {
//                                           // Register user
//                                           controller.register(
//                                             usernameController.text,
//                                             "fdsf",
//                                             phoneController.text,
//                                             passwordController.text,
//                                             upiIdController.text,
//                                           );
//                                         } else {
//                                           // Show error message
//                                           Get.snackbar('Error',
//                                               'Invalid OTP. Please try again.');
//                                         }
//                                       } else {
//                                         // Send OTP
//                                         verifyPhoneController.verifyPhoneNumber(
//                                             phoneController.text);
//                                       }
//                                     },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Theme.of(context).primaryColor,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: AnimatedSwitcher(
//                                 duration: Duration(milliseconds: 200),
//                                 child: controller.isLoading.value
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : Text(
//                                         verifyPhoneController.isOtpSent.value
//                                             ? 'Verify OTP'
//                                             : 'Send OTP',
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           )),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/AnimationWidget.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController controller = Get.find();
  final ThemeController themeController = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController upiIdController = TextEditingController();
  final RxString selectedImagePath = ''.obs;

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
                child: Text('Register'),
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
                    // Profile Picture Selection
                    FadeSlideTransition(
                      delay: 0.2,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Implement image picker
                          },
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 800),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
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
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            },
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
                    const SizedBox(height: 16),
                    // Phone Field
                    FadeSlideTransition(
                      delay: 0.6,
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
                    FadeSlideTransition(
                        delay: 0.4,
                        child: TextField(
                          controller:
                              upiIdController, // Your existing controller

                          decoration: InputDecoration(
                            labelText: 'UPI ID',
                            prefixIcon:
                                const Icon(Icons.account_balance_wallet),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )),

// Function to validate the UPI ID format

                    const SizedBox(height: 16),
                    // Password Field
                    FadeSlideTransition(
                      delay: 0.8,
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
                    const SizedBox(height: 32),
                    // Register Button
                    FadeSlideTransition(
                      delay: 1.0,
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
                                  : () => controller.register(
                                      usernameController.text,
                                      "fdsf",
                                      phoneController.text,
                                      passwordController.text,
                                      upiIdController.text,
                                      context),
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
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
