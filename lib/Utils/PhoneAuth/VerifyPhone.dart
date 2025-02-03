import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VerifyPhone extends GetxController {
  var _verificationId = ''.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    isLoading.value = true;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        isLoading.value = false;
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification Failed: ${e.message}');
        isLoading.value = false;
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId.value = verificationId;
        isOtpSent.value = true;
        isLoading.value = false;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId.value = verificationId;
        isLoading.value = false;
      },
    );
  }

  Future<bool> signInWithPhoneNumber(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId.value,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('User signed in successfully!');
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }
}
