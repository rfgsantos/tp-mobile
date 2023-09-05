import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String token = "TOKEN";
  static const String user = "USER";
  final SharedPreferences prefs;

  SharedPreferencesHelper({required this.prefs});

  Future<void> setUserToken({required String userToken}) async =>
      await prefs.setString(token, userToken);

  String? getUserToken() {
    final userToken = prefs.getString(token);
    return userToken;
  }

  Future<bool> removeUserToken() async {
    await prefs.remove(token);
    return await prefs.remove(user);
  }

  Future<void> setKeyValue(
          {required String key, required String value}) async =>
      await prefs.setString(key, value);

  Future<void> setKeyValueObject<T extends Map>(
          {required String key, required T value}) async =>
      await prefs.setString(key, json.encode(value));

  String? getKeyValue({required String key}) {
    final value = prefs.getString(key);
    return value;
  }
}
