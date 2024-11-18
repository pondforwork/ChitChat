import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserController extends GetxController {
  late Box _userBox;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox("user");
    super.onInit();
  }

  void saveUser(String userId, String username) {
    _userBox.put("userId", userId);
    _userBox.put("username", username);
    print("User data saved!");
  }

  Map<String, String?> getUser() {
    String? userId = _userBox.get("userId");
    String? username = _userBox.get("username");
    return {
      "userId": userId,
      "username": username,
    };
  }

  void clearUser() {
    _userBox.delete("userId");
    _userBox.delete("username");
    print("User data cleared!");
  }

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       return null; // User canceled the sign-in
  //     }

  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser.authentication;

  //     // Extract access token and ID token
  //     String? accessToken = googleAuth?.accessToken;
  //     String? idToken = googleAuth?.idToken;
  //     print("User id: ${googleUser.id}");
  //     print("User email: ${googleUser.email}");
  //     print("User name: ${googleUser.displayName}");

  //     // Log tokens or store them as needed
  //     print("Access Token: $accessToken");
  //     print("ID Token: $idToken");

  //     return null;
  //   } catch (error) {
  //     print("Error signing in with Google: $error");
  //     return null;
  //   }
  // }

  Future<User?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain Google Sign-In Authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the signed-in user
      final User? firebaseUser = userCredential.user;

      // Log user information
      print("Firebase User ID: ${firebaseUser?.uid}");
      print("User Email: ${firebaseUser?.email}");
      print("User Name: ${firebaseUser?.displayName}");

      return firebaseUser;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }
}
