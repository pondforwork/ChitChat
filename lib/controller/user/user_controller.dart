import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/model/local_user.dart';
import 'package:chit_chat/view/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserController extends GetxController {
  UserDbController realtimeDbController = Get.put(UserDbController());

  late Box _userBox;
  RxString userName = ''.obs;
  RxString userUid = ''.obs;
  RxString photoUrl = ''.obs;
  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox("user");
    super.onInit();
  }

  void saveLocalUser(String? userId, String? username, String? photoURL) {
    _userBox.put("userId", userId);
    _userBox.put("username", username);
    _userBox.put("photoURL", photoURL);

    print("User data saved!");
  }

  Future<LocalUser> getUser() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox("user");
    String? userIdString = await _userBox.get("userId");
    String? usernameString = await _userBox.get("username");
    String? photoURLString = await _userBox.get("photoURL");
    print(photoURLString);
    // If userId is retrieved, update the RxString values.
    if (userIdString != null &&
        usernameString != null &&
        photoURLString != null) {
      print("UserId not null");
      print(userUid.value);
      print(userIdString);
      userUid.value = userIdString;
      userName.value = usernameString;
      photoUrl.value = photoURLString;
    } else {
      print("User is Empty");
    }
    // Return the LocalUser object after updating values
    LocalUser user = LocalUser(userId: userUid.value, username: usernameString);
    return user;
  }

  void clearUser() {
    _userBox.delete("userId");
    _userBox.delete("username");
    print("User data cleared!");
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
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

      // ถ้าได้ firebase user
      if (firebaseUser != null) {
        String uid = firebaseUser.uid;
        print(uid);
        if (await realtimeDbController.checkUserExists(uid)) {
          Get.to(HomeView());
        } else {
          realtimeDbController.saveNewUserToFirebase(firebaseUser);
          saveLocalUser(firebaseUser.uid, firebaseUser.displayName,
              firebaseUser.photoURL);
          Get.to(HomeView());
        }
        saveLocalUser(
            firebaseUser.uid, firebaseUser.displayName, firebaseUser.photoURL);
      }

      return firebaseUser;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }
}
