import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class RegisterResult {
  final bool success;
  final String? errorMessage;
  RegisterResult(this.success, {this.errorMessage});
}

class LoginResult {
  final bool success;
  final String? errorMessage;
  LoginResult(this.success, {this.errorMessage});
}

class RemoteDatasource {
  Future<RegisterResult> register(UserModel user) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final createdUser = userCredential.user;

      if (createdUser != null) {
        return RegisterResult(true);
      } else {
        return RegisterResult(false,
            errorMessage: 'Registration failed. User not created.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email is already in use.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'Registration failed. ${e.message ?? 'Unknown error.'}';
      }
      return RegisterResult(false, errorMessage: message);
    } catch (e) {
      return RegisterResult(false, errorMessage: 'Unexpected error occurred.');
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        final token = await user.getIdToken();
        print(
            "User ID: ${user.uid}, Token: $token"); // You can store it if needed
        return LoginResult(true);
      } else {
        return LoginResult(false,
            errorMessage: 'Login failed. User not found.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-disabled':
          message = 'User account is disabled.';
          break;
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        default:
          message = 'Login failed. ${e.message ?? 'Unknown error.'}';
      }
      return LoginResult(false, errorMessage: message);
    } catch (e) {
      print(e);
      return LoginResult(false, errorMessage: 'Unexpected error occurred.');
    }
  }
}
