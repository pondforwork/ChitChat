import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListView extends StatefulWidget {
  const FriendListView({super.key});

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  UserController userController = UserController();
  UserDbController userDbController = UserDbController();

  @override
  void initState() {
    // Fetch friend list on initialization
    userDbController.getFriendsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend List"),
      ),
      body: Obx(() {
        // Observe the friend list
        if (userDbController.friendList.isEmpty) {
          return const Center(child: Text("No friends found."));
        }

        return ListView.builder(
          itemCount: userDbController.friendList.length,
          itemBuilder: (context, index) {
            final friend = userDbController.friendList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: friend.photoUrl != null
                    ? NetworkImage(friend.photoUrl!)
                    : null,
                child:
                    friend.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(friend.username ?? "Unknown"),
              subtitle: Text(friend.email ?? "No email provided"),
              trailing: const Icon(Icons.message),
              onTap: () {
                // Handle friend selection or messaging
                print("Tapped on: ${friend.username}");
              },
            );
          },
        );
      }),
    );
  }
}
