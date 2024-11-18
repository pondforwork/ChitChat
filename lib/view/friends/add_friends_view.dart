import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendsView extends StatefulWidget {
  const AddFriendsView({super.key});

  @override
  State<AddFriendsView> createState() => _AddFriendsViewState();
}

class _AddFriendsViewState extends State<AddFriendsView> {
  final TextEditingController _friendIdController = TextEditingController();
  RealtimeDbController userDbController = Get.put(RealtimeDbController());
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
            height: 150,
          ),
          Center(
            child: Form(
              key: _formKey, // Assign the form key to the Form widget
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    width: 270,
                    child: TextFormField(
                      controller: _friendIdController, // Connect the controller
                      decoration: InputDecoration(
                        hintText: 'ใส่ไอดีของเพื่อนที่นี่',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Set the border radius
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _validateAndSubmit();
                          },
                        ),
                      ),
                      // Add a validator to ensure the field is not empty
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกไอดีของเพื่อน'; // Error message when field is empty
                        }
                        return null; // If the field is not empty, return null
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Obx(() {
                    return userDbController.userFound.value
                        ? Container(
                            width: 100,
                            height: 200,
                            color: Colors.black38,
                            child: Column(
                              children: [Text(userDbController.userName.value)],
                            ),
                          )
                        : Text("Not Found");
                  })
                  // InkWell(
                  //   onTap: _validateAndSubmit, // Trigger validation on tap
                  //   borderRadius: BorderRadius.circular(15),
                  //   splashColor: Colors.green,
                  //   child: Ink(
                  //     width: 150,
                  //     height: 50,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(15),
                  //       color: Color(0xFFFFDDAE),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Icon(Icons.search),
                  //         const SizedBox(
                  //           width: 15,
                  //         ),
                  //         Text("ค้นหา",
                  //             style: GoogleFonts.kanit(
                  //               fontSize: 20,
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.bold,
                  //             )),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
