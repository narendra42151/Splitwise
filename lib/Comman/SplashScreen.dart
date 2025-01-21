import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/Utils/TokenFile.dart';
import 'package:splitwise/ViewModel/Controller/Auth.Controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  // Function to check user session and navigate accordingly
  Future<void> _checkUserSession() async {
    final accessToken = await SecureTokenManager()
        .getAccessToken(); // Get the saved access token

    if (accessToken != null) {
      // If there's an access token, attempt to fetch user details
      try {
        await authController.getUserDetails(); // Fetch user details
        // After fetching user details, navigate to home if successful
        Get.offAllNamed('/home');
      } catch (e) {
        // If fetching user details fails, navigate to login
        Get.offAllNamed('/login');
      }
    } else {
      // If no access token is found, navigate to login screen
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // The splash screen is shown while checking the user session
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          // Animated Background Pattern
          ...List.generate(20, (index) => _buildAnimatedDot(index)),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.payment,
                          size: 60,
                          color: AppColors.lightPrimaryColor,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40),

                // App Name Animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          'PayWise',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                // Tagline Animation
                DelayedTweenAnimation(
                  delay: Duration(milliseconds: 500),
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          'Smart Payments Made Simple',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 80),

                // Loading Indicator Animation
                DelayedTweenAnimation(
                  delay: Duration(milliseconds: 1000),
                  duration: Duration(milliseconds: 800),
                  builder: (context, value) {
                    return Opacity(
                      opacity: value,
                      child: _buildLoadingIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    final random = index * 0.1;
    return Positioned(
      left: 20 + (index * 40),
      top: 100 + (index * 30),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 1500 + (index * 100)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value * (0.5 + random),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 100,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Column(
            children: [
              LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Corrected DelayedTweenAnimation
class DelayedTweenAnimation extends StatefulWidget {
  final Widget Function(BuildContext, double) builder;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const DelayedTweenAnimation({
    required this.builder,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    Key? key,
  }) : super(key: key);

  @override
  _DelayedTweenAnimationState createState() => _DelayedTweenAnimationState();
}

class _DelayedTweenAnimationState extends State<DelayedTweenAnimation> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _startAnimation ? 1 : 0),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, child) {
        return widget.builder(context, value);
      },
    );
  }
}
