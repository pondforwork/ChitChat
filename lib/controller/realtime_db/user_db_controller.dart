import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../model/user.dart';

class UserDbController extends GetxController {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  RxBool isInitial = true.obs;
  RxBool userFound = false.obs;
  RxString userName = ''.obs;
  RxString friendUserId = ''.obs;
  RxString friendUid = ''.obs;
  RxString photoUrl = ''.obs;
  RxList friendList = <UserInstance>[].obs;

  void saveNewUserToFirebase(User? firebaseUser) {
    try {
      // Use the provided custom ID as the Firebase key
      DatabaseReference newUserRef = _userRef.child(firebaseUser!.uid);

      // Save user data with the provided custom ID as the _id
      newUserRef.set({
        '_id': firebaseUser.uid, // Use the custom ID here
        'username': firebaseUser.displayName ?? '',
        'photoUrl': firebaseUser.photoURL ?? '',
        'email': firebaseUser.email ?? '',
        'friends': [],
        'chats': [],
        'userId': '',
      }).then((_) {
        print('User saved successfully with _id: ${firebaseUser.uid}');
      }).catchError((error) {
        print('Failed to save User: $error');
      });
    } catch (error) {
      print('Error saving user: $error');
    }
  }

  Future<bool> checkUserExistInDb(String uid) async {
    final snapshot = await _userRef.child('users/$uid').get();
    if (snapshot.exists) {
      print(snapshot.value);
      return true;
    } else {
      print('No data available.');
      return false;
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
        // print("Raw Snapshot Value: ${snapshot.value}");
        final userData = snapshot.value as Map<dynamic, dynamic>;
        final firstEntry = userData.entries.first;
        final userMap = Map<String, dynamic>.from(firstEntry.value);
        // Handle friends as a Map<String, dynamic>
        final friendsData = userMap['friends'] as Map<dynamic, dynamic>? ?? {};
        final friendsList = friendsData.entries
            .map((entry) {
              final friendMap = Map<String, dynamic>.from(entry.value);
              return friendMap['username'] ??
                  ''; // Extract the friend's username
            })
            .toList()
            .cast<String>(); // Explicitly cast to List<String>

        // Create UserInstance
        UserInstance user = UserInstance(
          id: userMap['_id'] ?? '',
          username: userMap['username'] ?? '',
          friends: friendsList, // Assign as List<String>
          chats: userMap['chats'] != null
              ? (userMap['chats'] as Map<dynamic, dynamic>)
                  .keys
                  .map((key) => key.toString())
                  .toList()
              : [],
          email: userMap['email'] ?? '',
          userId: userMap['userId'] ?? '',
          photoUrl: userMap['photoUrl'],
        );

        print("Username: ${user.username}");
        userName.value = user.username;
        this.friendUserId.value = user.userId;
        friendUid.value = user.id;
        userFound.value = true;
        photoUrl.value = user.photoUrl ?? '';
      } else {
        print("No user found with userId: $userId");
      }
    } catch (e) {
      print("Error finding user by ID: $e");
    }
  }

  // void addFriend(String userUid, String friendUid) async {
  //   try {
  //     // Step 1: Find the user object by `userUid`
  //     Query userQuery = _userRef.orderByChild('_id').equalTo(userUid);
  //     DatabaseEvent userEvent = await userQuery.once();
  //     DataSnapshot userSnapshot = userEvent.snapshot;

  //     if (!userSnapshot.exists) {
  //       print('User not found with userUid: $userUid');
  //       return;
  //     }

  //     // Extract user object
  //     Map<dynamic, dynamic> userData =
  //         userSnapshot.value as Map<dynamic, dynamic>;
  //     String userKey =
  //         userData.keys.first; // Assuming a single user is returned
  //     Map<dynamic, dynamic> userObject = userData[userKey];

  //     // Step 2: Find the friend object by `friendUid`
  //     Query friendQuery = _userRef.orderByChild('_id').equalTo(friendUid);
  //     DatabaseEvent friendEvent = await friendQuery.once();
  //     DataSnapshot friendSnapshot = friendEvent.snapshot;

  //     if (!friendSnapshot.exists) {
  //       print('Friend not found with friendUid: $friendUid');
  //       return;
  //     }

  //     // Extract friend object
  //     Map<dynamic, dynamic> friendData =
  //         friendSnapshot.value as Map<dynamic, dynamic>;
  //     String friendKey =
  //         friendData.keys.first; // Assuming a single friend is returned
  //     Map<dynamic, dynamic> friendObject = friendData[friendKey];

  //     // Step 3: Prepare user and friend objects to insert into each other's lists
  //     Map<String, dynamic> userToInsert = {
  //       '_id': userObject['_id'] ?? '',
  //       'lastMessage': '',
  //       'lastMessageTime': '',
  //       'photoUrl': userObject['photoUrl'] ?? '',
  //       'status': 'friend',
  //       'userId': userObject['userId'] ?? '',
  //       'username': userObject['username'] ?? '',
  //     };

  //     Map<String, dynamic> friendToInsert = {
  //       '_id': friendObject['_id'] ?? '',
  //       'lastMessage': '',
  //       'lastMessageTime': '',
  //       'photoUrl': friendObject['photoUrl'] ?? '',
  //       'status': 'friend',
  //       'userId': friendObject['userId'] ?? '',
  //       'username': friendObject['username'] ?? '',
  //     };

  //     // Step 4: Insert friend into user's friends list
  //     DatabaseReference userFriendsRef = _userRef.child('$userKey/friends');
  //     DatabaseReference newFriendRefForUser = userFriendsRef.push();
  //     await newFriendRefForUser.set(friendToInsert);

  //     // Step 5: Insert user into friend's friends list
  //     DatabaseReference friendFriendsRef = _userRef.child('$friendKey/friends');
  //     DatabaseReference newFriendRefForFriend = friendFriendsRef.push();
  //     await newFriendRefForFriend.set(userToInsert);

  //     print('Friends added successfully!');
  //   } catch (error) {
  //     print('Error adding friend: $error');
  //   }
  // }

  void addFriend(String userUid, String friendUid) async {
    try {
      // Step 1: Find the user object by `userUid`
      Query userQuery = _userRef.orderByChild('_id').equalTo(userUid);
      DatabaseEvent userEvent = await userQuery.once();
      DataSnapshot userSnapshot = userEvent.snapshot;

      if (!userSnapshot.exists) {
        print('User not found with userUid: $userUid');
        return;
      }

      // Extract user object
      Map<dynamic, dynamic> userData =
          userSnapshot.value as Map<dynamic, dynamic>;
      String userKey =
          userData.keys.first; // Assuming a single user is returned
      Map<dynamic, dynamic> userObject = userData[userKey];

      // Step 2: Find the friend object by `friendUid`
      Query friendQuery = _userRef.orderByChild('_id').equalTo(friendUid);
      DatabaseEvent friendEvent = await friendQuery.once();
      DataSnapshot friendSnapshot = friendEvent.snapshot;

      if (!friendSnapshot.exists) {
        print('Friend not found with friendUid: $friendUid');
        return;
      }

      // Extract friend object
      Map<dynamic, dynamic> friendData =
          friendSnapshot.value as Map<dynamic, dynamic>;
      String friendKey =
          friendData.keys.first; // Assuming a single friend is returned
      Map<dynamic, dynamic> friendObject = friendData[friendKey];

      // Step 3: Prepare user and friend objects to insert into each other's lists
      Map<String, dynamic> userToInsert = {
        '_id': userObject['_id'] ?? '',
        'lastMessage': '',
        'lastMessageTime': '',
        'photoUrl': userObject['photoUrl'] ?? '',
        'status': 'friend',
        'userId': userObject['userId'] ?? '',
        'username': userObject['username'] ?? '',
      };

      Map<String, dynamic> friendToInsert = {
        '_id': friendObject['_id'] ?? '',
        'lastMessage': '',
        'lastMessageTime': '',
        'photoUrl': friendObject['photoUrl'] ?? '',
        'status': 'friend',
        'userId': friendObject['userId'] ?? '',
        'username': friendObject['username'] ?? '',
      };

      // Step 4: Insert friend into user's friends list using `_id` as the key
      DatabaseReference userFriendsRef =
          _userRef.child('$userKey/friends/${friendObject['_id']}');
      await userFriendsRef.set(friendToInsert);

      // Step 5: Insert user into friend's friends list using `_id` as the key
      DatabaseReference friendFriendsRef =
          _userRef.child('$friendKey/friends/${userObject['_id']}');
      await friendFriendsRef.set(userToInsert);

      print('Friends added successfully with custom keys!');
    } catch (error) {
      print('Error adding friend: $error');
    }
  }

  Future<List<UserInstance>> getFriendsList() async {
    try {
      String myUserId = 'LlpNuYauPAhoyCqreYF6PBQhenD2';

      // Query to find the user by userId
      Query userQuery = _userRef.orderByChild('_id').equalTo(myUserId);
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Extract the user key and fetch the friends list
        Map<String, dynamic> userMap =
            Map<String, dynamic>.from(snapshot.value as Map);
        String userKey = userMap.keys.first;
        List<dynamic> friendIds = userMap[userKey]['friends'] ?? [];

        // Fetch friend details based on friendIds
        List<UserInstance> friends = [];
        for (String friendId in friendIds.cast<String>()) {
          Query friendQuery = _userRef.orderByChild('_id').equalTo(friendId);
          DatabaseEvent friendEvent = await friendQuery.once();
          DataSnapshot friendSnapshot = friendEvent.snapshot;

          if (friendSnapshot.exists) {
            // Assuming each friend entry has a single user object
            Map<String, dynamic> friendMap =
                Map<String, dynamic>.from(friendSnapshot.value as Map);
            String friendKey = friendMap.keys.first;
            Map<String, dynamic> friendData =
                Map<String, dynamic>.from(friendMap[friendKey]);
            friends.add(UserInstance.fromMap(friendData));
            friendList.add(UserInstance.fromMap(friendData));
          }
        }
        print("FriendList");
        print(friends);
        print(friendList);
        return friends;
      } else {
        print('User with userId "$myUserId" not found.');
        return [];
      }
    } catch (error) {
      print('Error fetching friends list: $error');
      return [];
    }
  }
}
