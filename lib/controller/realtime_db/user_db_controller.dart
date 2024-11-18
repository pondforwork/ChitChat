import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../model/user.dart';

class RealtimeDbController extends GetxController {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  RxBool userFound = false.obs;
  RxString userName = ''.obs;

  void saveNewUserToFirebase(User? firebaseUser) {
    _userRef.push().set({
      '_id': firebaseUser!.uid,
      'username': firebaseUser.displayName,
      'friends': [],
      'chats': [],
      'userId': ''
    }).then((_) {
      print('save user success');
    }).catchError((error) {
      print('Failed to save User');
    });
  }

  Future<void> checkUserExistInDb(String userId) async {
    final snapshot = await _userRef.child('users/$userId').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }
  }

  Future<void> getAllUsers() async {
    try {
      // Fetch all data under 'users' node
      DatabaseEvent event = await _userRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Loop through the users data
        Map<dynamic, dynamic> usersData = snapshot.value as Map;
        usersData.forEach((key, value) {
          print('User Key: $key');
          print('User Data: $value');
        });
      } else {
        print('No users found');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      Query userQuery = _userRef.orderByChild('_id').equalTo(userId);
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // The user exists
        Map userData = snapshot.value as Map;
        print('User found: $userData');
        return true;
      } else {
        print('No user found with ID: $userId');
        return false;
      }
    } catch (error) {
      print('Error finding user: $error');
      return false;
    }
  }

  Future<void> findFriendsById(String userId) async {
    try {
      userFound.value = false;

      Query userQuery = _userRef.orderByChild('userId').equalTo(userId);
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        print("Raw Snapshot Value: ${snapshot.value}");
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        Map<String, dynamic> userMap =
            Map<String, dynamic>.from(userData.values.first);
        UserInstance user = UserInstance.fromMap(userMap);
        print("Username: ${user.username}");
        userName.value = user.username;
        userFound.value = true;
      } else {
        print("No user found with userId: $userId");
      }
    } catch (e) {
      print("Error finding user by ID: $e");
    }
  }
}
