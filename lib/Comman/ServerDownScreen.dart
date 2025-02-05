import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/SplashScreen.dart';

class ServerDownScreen extends StatelessWidget {
  final bool isLogin;

  final bool server;
  const ServerDownScreen(
      {required this.isLogin, required this.server, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 100,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                server
                    ? 'Server Unavailable'
                    : "WE'RE UNABLE TO LOAD PAGE DATA",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                server
                    ? 'It looks like the server is currently down. Please check your connection or try again later.'
                    : 'Please check your internet connection or try again later',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  isLogin ? Get.to(() => SplashScreen()) : Get.toNamed("/home");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
