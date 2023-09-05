import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpmobile/services/internet_connection.dart';
import 'package:tpmobile/services/plan_repository.dart';
import 'package:tpmobile/services/teams_repository.dart';
import 'package:tpmobile/services/user_repository.dart';
import 'package:tpmobile/services/util_service.dart';
import 'package:tpmobile/utils/shared_preferences_helper.dart';

import '../utils/dio/dio_client.dart';
import 'authentication_repository.dart';
import 'notification_service.dart';
import 'osm_repository.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferencesHelper>(
      SharedPreferencesHelper(prefs: prefs));
  getIt.registerSingleton(InternetConnectionService());
  getIt.registerSingleton(NotificationService());
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<OSMRepository>(OSMRepository());
  getIt.registerSingleton<TeamsRepository>(TeamsRepository());
  getIt.registerSingleton<PlansRepository>(PlansRepository());
  getIt.registerSingleton<AuthenticationRepository>(AuthenticationRepository());
  getIt.registerSingleton<UserRepository>(UserRepository());
  getIt.registerSingleton<UtilService>(UtilService());
}
