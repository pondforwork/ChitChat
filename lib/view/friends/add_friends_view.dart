import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendsView extends StatefulWidget {
  const AddFriendsView({super.key});

  @override
  State<AddFriendsView> createState() => _AddFriendsViewState();
}

class _AddFriendsViewState extends State<AddFriendsView> {
  @override
  void dispose() {
    userDbController.userFound.value = false;
    userDbController.isInitial.value = true;
    _friendIdController.clear();
    super.dispose();
  }

  final TextEditingController _friendIdController = TextEditingController();
  RealtimeDbController userDbController = Get.put(RealtimeDbController());
  UserController userController = Get.put(UserController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // print("Form is valid: ${_friendIdController.text}");
      userDbController.findFriendsById(_friendIdController.text);
    } else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDDAE),
        title: Text("เพิ่มเพื่อน",
            style: GoogleFonts.kanit(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 120,
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    width: 270,
                    child: TextFormField(
                      controller: _friendIdController,
                      decoration: InputDecoration(
                        hintText: 'ใส่ไอดีของเพื่อนที่นี่',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _validateAndSubmit();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกไอดีของเพื่อน';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Obx(() {
                    return !userDbController.isInitial.value
                        ? userDbController.userFound.value
                            ? Container(
                                // color: Colors.black38,
                                child: Column(
                                  children: [
                                    Container(
                                        child: CircleAvatar(
                                      radius:
                                          75, // Half of the 150 size to make it a circle
                                      backgroundImage: NetworkImage(
                                        userDbController
                                                .photoUrl.value.isNotEmpty
                                            ? userDbController.photoUrl.value
                                            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSe_cHoMuGA2eCU5W8DnuQQfwzzvcMyBX0rOQ&s', // Fallback image
                                      ),
                                    )),
                                    Text(
                                      userDbController.userName.value,
                                      style: GoogleFonts.kanit(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        userDbController.addFriend("Test",
                                            userDbController.friendUid.value);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: Color(0xFFFFDDAE),
                                      child: Ink(
                                        width: 160,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Color(0xFFFFDDAE),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("เพิ่มเพื่อน",
                                                style: GoogleFonts.kanit(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text("ไม่พบผู้ใช้ที่ต้องการ")
                        : Container();
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
