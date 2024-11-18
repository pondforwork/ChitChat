import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
          ),
          Center(
            child: Center(
              child: InkWell(
                onTap: () {
                  print("Login Clicked");
                },
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.green, // Customize splash color
                child: Ink(
                  width: 300,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFFFDDAE),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("เข้าสู่ระบบด้วย Google",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
