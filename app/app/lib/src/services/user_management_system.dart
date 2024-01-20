import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

class UserManagementSystem {
  static const sharedPrefsUserIdKey = 'userId';

  static String? rootApiUrl;
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<String?> registerUser(File handwritingImage) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$rootApiUrl/register'));
    request.files.add(http.MultipartFile.fromBytes(
        "handwriting_image", handwritingImage.readAsBytesSync(),
        filename: handwritingImage.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var results = json.decode(response.body);
      var userId = results["data"]["id"];

      prefs.setString(sharedPrefsUserIdKey, userId);
      return userId;
    } else {
      return null;
    }
  }

  static bool isRegistered() {
    return getLocalUserId() != null;
  }

  static String? getLocalUserId() {
    return prefs.getString(sharedPrefsUserIdKey);
  }
}
