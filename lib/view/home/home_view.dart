import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
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
    userController.getUser();
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
          leading: const Icon(Icons.image),
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
        body: IndexedStack(
          index:
              _selectedIndex, // Display the selected page from the _pages list
          children: _pages, // All pages are kept alive in the background
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Current selected tab index
          onTap: _onItemTapped, // Handle tab selection
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            userDbController.getFriendsList(userController.userUid.value);
          }),
        ));
  }
}

// Sample Pages (Replace these with your actual page widgets)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen'),
    );
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
