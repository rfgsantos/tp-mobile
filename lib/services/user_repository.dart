import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tpmobile/services/urls.dart';

import '../models/user.dart';
import '../utils/dio/dio_client.dart';
import 'setup_di.dart';

class UserRepository {
  final DioClient _dioClient = getIt<DioClient>();

  Future<bool> usernameExists(String username) {
    return _dioClient.dio
        .get("${AppUrls.baseUrl}${AppUrls.cms}/users/username/exists/$username")
        .asStream()
        .map((Response<dynamic> value) => value.data)
        .cast<bool>()
        .single;
  }

  Future<List<User>> getUserByEmail(String email) {
    return _dioClient.dio
        .get("${AppUrls.baseUrl}${AppUrls.cms}/users/email/$email")
        .asStream()
        .map((Response<dynamic> value) =>
            (value.data as List).map((e) => User.fromJson(e)).toList())
        .single;
  }

  Future<User> saveProfile(XFile? file, User user) async {
    FormData formData = FormData.fromMap({
      "profile_image":
          await MultipartFile.fromFile(file?.path ?? "", filename: file?.name),
      ...user.toJson()
    });
    return _dioClient.dio
        .post("${AppUrls.baseUrl}${AppUrls.cms}/users/profile/update",
            data: formData)
        .asStream()
        .map((Response<dynamic> event) => User.fromJson(event.data))
        .single;
  }
}
