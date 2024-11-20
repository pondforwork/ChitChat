import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFDDAE),
          title: Text(
            "บัญชีของฉัน",
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          return Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
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
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                userController.userName.value,
                style: GoogleFonts.kanit(
                    fontWeight: FontWeight.normal, fontSize: 25),
              ),
              Text("ไอดี : ${userController.userUid.value}",
                  style: GoogleFonts.kanit(
                      fontWeight: FontWeight.normal, fontSize: 25))
            ],
          );
        }));
  }
}
