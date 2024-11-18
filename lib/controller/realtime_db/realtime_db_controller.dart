import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDbController {
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

// "_id": "userId1", //Id จาก Google
//   "username": "UserOne",
//   "friends": firendshipid1,
//   "chats": ["chatId1", "chatId2"],
//   "userId" : "pondzaa,bigpim"

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

  Future<void> getUserById(String userId) async {
    try {
      // Query users by '_id' field
      Query userQuery = _userRef.orderByChild('_id').equalTo(userId);

      // Fetch data once from the query
      DatabaseEvent event = await userQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // The user exists
        Map userData = snapshot.value as Map;
        print('User found: $userData');
      } else {
        print('No user found with ID: $userId');
      }
    } catch (error) {
      print('Error finding user: $error');
    }
  }
}
