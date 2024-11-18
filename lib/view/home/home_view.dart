import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:chit_chat/view/friends/add_friends_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  UserController userController = Get.put(UserController());
  RealtimeDbController realtimeDbController = Get.put(RealtimeDbController());
  @override
  void initState() {
    // TODO: implement initState
    userController.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDDAE),
        leading: const Icon(Icons.image),
        title: Obx((() {
          return Text(
            userController.userName.value,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
            ),
          );
        })),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (() {
                print("Add Friend");
                Get.to(AddFriendsView());
              }),
              icon: const Icon(Icons.person_add))
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (() {
        realtimeDbController.getFriendsList(userController.userId.value);
      })),
    );
  }
}
