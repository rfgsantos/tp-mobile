import 'package:dio/dio.dart';
import 'package:tpmobile/utils/shared_preferences_helper.dart';

import '../../services/setup_di.dart';

class DioInterceptor extends Interceptor {
  static const String authorizationKey = 'Authorization';

  final SharedPreferencesHelper _prefsLocator =
      getIt.get<SharedPreferencesHelper>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_prefsLocator.getUserToken() != null) {
      options.headers[authorizationKey] =
          "Bearer ${_prefsLocator.getUserToken()}";
    }

    super.onRequest(options, handler);
  }
}
