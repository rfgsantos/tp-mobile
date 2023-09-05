import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpmobile/models/team.dart';
import 'package:tpmobile/services/setup_di.dart';
import 'package:tpmobile/services/urls.dart';
import 'package:tpmobile/utils/dio/dio_client.dart';

class TeamsRepository {
  final BehaviorSubject<List<Role>> _roleController =
      BehaviorSubject<List<Role>>();
  final DioClient _dioClient = getIt<DioClient>();

  List<Role> get roles => _roleController.value;

  void initRoles() {
    if (!_roleController.hasValue) {
      getRoles().then((List<Role> value) => _roleController.add(value));
    }
  }

  Future<List<Team>> getMyTeams() => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.cms}/team/myteams")
      .asStream()
      .map((Response<dynamic> event) =>
          (event.data as List).map((e) => Team.fromJson(e)).toList())
      .single;

  Future<bool> teamNameExists(String name) => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.cms}/team/exists/$name")
      .asStream()
      .map((Response<dynamic> event) => event.data as bool)
      .single;

  Future<List<Role>> getRoles() => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.cms}/team/roles")
      .asStream()
      .map((Response<dynamic> event) =>
          (event.data as List).map((e) => Role.fromJson(e)).toList())
      .single;

  Future<Team> updateTeam(Team team) => _dioClient.dio
      .post("${AppUrls.baseUrl}${AppUrls.cms}/team/update", data: team.toJson())
      .asStream()
      .map((Response<dynamic> event) => Team.fromJson(event.data))
      .single;

  Future<Team> saveTeam(Team team) => _dioClient.dio
      .post("${AppUrls.baseUrl}${AppUrls.cms}/team/save", data: team.toJson())
      .asStream()
      .map((Response<dynamic> event) => Team.fromJson(event.data))
      .single;

  Future<void> deleteTemMemberById(int teamId, int memberId) => _dioClient.dio
      .delete("${AppUrls.baseUrl}${AppUrls.cms}/team/$teamId/$memberId");

  Future<Team> addImageToTeam(XFile? file, int? teamId) async {
    FormData formData = FormData.fromMap({
      "image":
          await MultipartFile.fromFile(file?.path ?? "", filename: file?.name)
    });
    return _dioClient.dio
        .post("${AppUrls.baseUrl}${AppUrls.cms}/team/image/$teamId",
            data: formData)
        .asStream()
        .map((Response<dynamic> event) => Team.fromJson(event.data))
        .single;
  }
}
