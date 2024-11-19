import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:flutter/material.dart';

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
    userDbController.getFriendsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text("Friend List")],
      ),
    );
  }
}
