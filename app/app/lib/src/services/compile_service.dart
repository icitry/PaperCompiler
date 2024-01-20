import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompileService {
  static String? rootApiUrl;

  static Future<Map<String, String>?> getAvailableLanguages() async {
    final response = await http.get(Uri.parse('$rootApiUrl/languages'));

    if (response.statusCode == 200) {
      Map<String, dynamic> results = json.decode(response.body)["data"];
      Map<String, String> parsedResults =
          results.map((key, value) => MapEntry(key, value.toString()));
      return parsedResults;
    } else {
      return null;
    }
  }

  static Future<Image?> compileCode(
    File codeImage,
    File? codeInputImage,
    String languageId,
    String userId,
  ) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$rootApiUrl/compile'));

    request.fields['language_id'] = languageId;
    request.fields['user_id'] = userId;

    request.files.add(http.MultipartFile.fromBytes(
        "code_image", codeImage.readAsBytesSync(),
        filename: codeImage.path));

    if (codeInputImage != null) {
      request.files.add(http.MultipartFile.fromBytes(
          "code_input_image", codeInputImage.readAsBytesSync(),
          filename: codeInputImage.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var resImage = Image.memory(response.bodyBytes);
      return resImage;
    } else {
      return null;
    }
  }
}
