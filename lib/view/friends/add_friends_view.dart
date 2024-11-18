import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendsView extends StatefulWidget {
  const AddFriendsView({super.key});

  @override
  State<AddFriendsView> createState() => _AddFriendsViewState();
}

class _AddFriendsViewState extends State<AddFriendsView> {
  // Create a TextEditingController to manage the text input
  final TextEditingController _friendIdController = TextEditingController();

  // Create a GlobalKey to manage the form state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Method to validate the form
  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed with the action
      print("Form is valid: ${_friendIdController.text}");
    } else {
      // If the form is invalid, show an error message
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
                  InkWell(
                    onTap: _validateAndSubmit, // Trigger validation on tap
                    borderRadius: BorderRadius.circular(15),
                    splashColor: Colors.green,
                    child: Ink(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFFFDDAE),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(
                            width: 15,
                          ),
                          Text("ค้นหา",
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
