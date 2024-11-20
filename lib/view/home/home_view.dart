import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:chit_chat/view/account/account_view.dart';
import 'package:chit_chat/view/chat/all_chat_view.dart';
import 'package:chit_chat/view/friends/add_friends_view.dart';
import 'package:chit_chat/view/friends/friend_list_view.dart';
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
  UserDbController userDbController = Get.put(UserDbController());
  ChatDbController chatDbController = Get.put(ChatDbController());
  // To track the selected tab
  int _selectedIndex = 0;

  // List of Pages (screens) for each tab
  List<Widget> _pages = [
    HomePage(), // Replace with actual Home page widget
    FriendsPage(), // Replace with actual Friends page widget
    SettingsPage(), // Replace with actual Settings page widget
  ];

  @override
  void initState() {
    super.initState();
    chatDbController.getFriendsList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change the selected tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDDAE),
        leading: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    userController.photoUrl.value.isNotEmpty
                        ? userController.photoUrl.value
                        : userController.defaultPhotoUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
        title: Obx(() {
          return Text(
            userController.userName.value,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              print("Add Friend");
              Get.to(AddFriendsView());
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      drawer: Drawer(
          backgroundColor: const Color(0xFFFFDDAE),
          // Sidebar Drawer
          child: ListView(padding: EdgeInsets.zero, children: [
            const SizedBox(
              height: 50,
            ),
            ListTile(
              title: const Text('บัญชีของฉัน'),
              leading: const Icon(Icons.account_box),
              onTap: () {
                Get.to(AccountView());
              },
            ),
            const Divider(
              color: Colors.white,
            ),
            ListTile(
              title: const Text('ออกจากระบบ'),
              leading: const Icon(Icons.logout),
              onTap: () {
                print("Logout");
              },
            ),
          ])),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (() {
      //     chatDbController.getFriendsList();
      //   }),
      //   child: Icon(Icons.refresh),
      // )
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AllChatView();
  }
}

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FriendListView();
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Screen'),
    );
  }
}
