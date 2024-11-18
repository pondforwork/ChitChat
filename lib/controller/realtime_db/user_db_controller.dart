import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../model/user.dart';

class RealtimeDbController extends GetxController {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  RxBool isInitial = true.obs;
  RxBool userFound = false.obs;
  RxString userName = ''.obs;
  RxString friendUserId = ''.obs;
  RxString friendUid = ''.obs;
  RxString photoUrl = ''.obs;

  void saveNewUserToFirebase(User? firebaseUser) {
    _userRef.push().set({
      '_id': firebaseUser!.uid,
      'username': firebaseUser.displayName,
      'photoUrl': '',
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
      isInitial.value = false;
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
        this.friendUserId.value = user.userId;
        friendUid.value = user.id;
        userFound.value = true;
        photoUrl.value = user.photoUrl!;
      } else {
        print("No user found with userId: $userId");
      }
    } catch (e) {
      print("Error finding user by ID: $e");
    }
  }

  void addFriend(String userId, String friendUid) async {
    try {
      // Search for the user by userId
      Query userQuery = _userRef.orderByChild('userId').equalTo(userId);
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Extract the first user's key (Firebase auto-generated key)
        String userKey = (snapshot.value as Map).keys.first;

        // Retrieve the current friends list or initialize it if absent
        List<dynamic> friends = List<dynamic>.from(
            (snapshot.value as Map)[userKey]['friends'] ?? []);

        // Add the friend's uid (friendUid) if not already in the list
        if (!friends.contains(friendUid)) {
          friends.add(friendUid);

          // Update the friends list in Firebase
          await _userRef.child(userKey).update({'friends': friends});
          print(
              'Friend (UID: $friendUid) added successfully to $userId\'s list.');
        } else {
          print('Friend (UID: $friendUid) is already in the list.');
        }
      } else {
        print('User with userId "$userId" not found.');
      }
    } catch (error) {
      print('Error adding friend: $error');
    }
  }

  void getFriendsList(String myUserId) async {
    try {
      Query userQuery = _userRef.orderByChild('_id').equalTo(myUserId);
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        String userKey = (snapshot.value as Map).keys.first;
        List<dynamic> friends =
            (snapshot.value as Map)[userKey]['friends'] ?? [];
        print("Friends List: $friends");
        List<String> friendIds = List<String>.from(friends);
        print("Friend IDs: $friendIds");
      } else {
        print("User with _id: $myUserId not found.");
      }
    } catch (error) {
      print("Error retrieving friends list: $error");
    }
  }
}
