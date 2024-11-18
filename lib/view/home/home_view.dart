import 'package:chit_chat/controller/user/user_controller.dart';
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
      ),
    );
  }
}
