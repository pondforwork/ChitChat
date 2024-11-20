import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:chit_chat/model/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListView extends StatefulWidget {
  const FriendListView({super.key});

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  UserController userController = UserController();
  UserDbController userDbController = Get.put(UserDbController());
  ChatDbController chatDbController = Get.put(ChatDbController());

  @override
  void initState() {
    super.initState();
    // Fetch the initial friend list when the widget is first created
    chatDbController.getFriendsList();
  }

  // The refresh function to be triggered on pull-to-refresh
  Future<void> _refreshFriendList() async {
    // Add the logic to refresh the friend list
    await chatDbController.getFriendsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // If no friends are found, display a message
        if (userDbController.friendListObx.isEmpty) {
          return const Center(child: Text("ไม่พบเพื่อนของคุณ"));
        }

        // Wrap ListView.builder with RefreshIndicator to enable pull-to-refresh
        return RefreshIndicator(
          onRefresh:
              _refreshFriendList, // The function that will be called on refresh
          child: ListView.builder(
            itemCount: userDbController.friendListObx.length,
            itemBuilder: (context, index) {
              final friend = userDbController.friendListObx[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.photoURL != null
                      ? NetworkImage(friend.photoURL!)
                      : null,
                  child:
                      friend.photoURL == null ? const Icon(Icons.person) : null,
                ),
                title: Text(friend.username ?? "Unknown"),
                subtitle: Text(friend.lastMessage ?? "Unknown"),
                onTap: () {
                  // Handle friend selection or messaging
                  chatDbController.startPrivateChat(
                      userController.getUserUid(), friend.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
