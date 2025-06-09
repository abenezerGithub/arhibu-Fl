import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  static User? getLoggeduser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  static Future<String?> getUserToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    } else {
      return null;
    }
  }
}
