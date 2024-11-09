import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_pages.dart';  // Ensure you have the correct route file imported

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Updated login method to handle routing after success
  Future<bool> login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Attempt Firebase login
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        // Save login state and user ID in SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userCredential.user!.uid);

        // Show success message
        Get.snackbar('Success', 'Logged in successfully',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Check if the email is the admin email
        if (email == 'admin@yahoo.com') {
          // Navigate to Admin Home page
          Get.offAllNamed(Routes.HOME_ADMIN);
        } else {
          // Navigate to regular Home page
          Get.offAllNamed(Routes.HOME);
        }

        return true; // Indicate success
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else {
          message = 'Login failed. Please try again!';
        }
        Get.snackbar('Login Failed', message,
            backgroundColor: Colors.red, colorText: Colors.white);
        return false; // Indicate failure
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false; // Indicate failure
      }
    } else {
      Get.snackbar('Error', 'Please enter email and password',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false; // Indicate failure
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
