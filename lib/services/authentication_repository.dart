import 'dart:async';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpmobile/models/user.dart';
import 'package:tpmobile/services/urls.dart';
import 'package:tpmobile/utils/dio/dio_client.dart';
import 'package:tpmobile/utils/shared_preferences_helper.dart';
import 'dart:convert';

import '../models/login.dart';
import '../models/register.dart';
import 'setup_di.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated, offline }

class AuthenticationRepository {
  final BehaviorSubject<AuthenticationStatus> _statusController =
      BehaviorSubject<AuthenticationStatus>();
  final BehaviorSubject<User> _userController = BehaviorSubject<User>();

  final DioClient _dioClient = getIt<DioClient>();
  final SharedPreferencesHelper _prefs = getIt<SharedPreferencesHelper>();

  Stream<AuthenticationStatus> get statusStream => _statusController.stream;

  Sink<AuthenticationStatus> get statusSink => _statusController.sink;

  Stream<User> get userStream => _userController.stream;

  Sink<User> get userSink => _userController.sink;

  User get user => _userController.value;

  AuthenticationStatus get status => _statusController.value;

  Future<TokenResponse> logIn(LoginInfo loginInfo) async {
    return _dioClient.dio
        .post("${AppUrls.baseUrl}${AppUrls.cms}/auth/login",
            data: loginInfo.toJson())
        .asStream()
        .map((value) => TokenResponse.fromJson(value.data))
        .single;
  }

  Future<Response> validateToken(String token) {
    return _dioClient.dio.post("${AppUrls.baseUrl}${AppUrls.cms}/auth/validate",
        data: {"token": token});
  }

  Future<User> getUserDetails() {
    return _dioClient.dio
        .get("${AppUrls.baseUrl}${AppUrls.cms}/auth/currentuser")
        .asStream()
        .map((Response<dynamic> value) => User.fromJson(value.data))
        .single;
  }

  Future<Register> register(Register register) {
    return _dioClient.dio
        .post("${AppUrls.baseUrl}${AppUrls.cms}/auth/register",
            data: register.toJson())
        .asStream()
        .map((Response<dynamic> value) => Register.fromJson(value.data))
        .single;
  }

  void checkAndValidateToken() {
    String? token = _prefs.getUserToken();
    if (token != null) {
      validateToken(token).then((value) {
        if (!value.data["valid"]) {
          _prefs.removeUserToken();
          statusSink.add(AuthenticationStatus.unauthenticated);
        } else {
          statusSink.add(AuthenticationStatus.authenticated);
          getUserDetails().then((value) {
            userSink.add(value);
            _prefs.setKeyValueObject<Map<String, dynamic>>(
                key: SharedPreferencesHelper.user, value: value.toJson());
          });
        }
      });
    } else {
      statusSink.add(AuthenticationStatus.unauthenticated);
    }
  }

  void printShared() {
    print(User.fromJson(json
        .decode(_prefs.getKeyValue(key: SharedPreferencesHelper.user) ?? "")));
  }

  void logOut() {
    _prefs.removeUserToken().then((value) {
      if (value) {
        _statusController.add(AuthenticationStatus.unauthenticated);
      }
    });
  }

  void dispose() => _statusController.close();
}
