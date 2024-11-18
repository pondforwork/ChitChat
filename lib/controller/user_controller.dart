import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserController extends GetxController {
  late Box _userBox;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox("user");
    super.onInit();
  }

  void saveUser(String userId, String username) {
    _userBox.put("userId", userId);
    _userBox.put("username", username);
    print("User data saved!");
  }

  Map<String, String?> getUser() {
    String? userId = _userBox.get("userId");
    String? username = _userBox.get("username");
    return {
      "userId": userId,
      "username": username,
    };
  }

  void clearUser() {
    _userBox.delete("userId");
    _userBox.delete("username");
    print("User data cleared!");
  }
}
