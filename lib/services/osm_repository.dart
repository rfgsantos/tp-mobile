import 'package:dio/dio.dart';
import 'package:tpmobile/models/osm_data.dart';
import 'package:tpmobile/services/setup_di.dart';
import 'package:tpmobile/services/urls.dart';
import 'package:tpmobile/utils/dio/dio_client.dart';

class OSMRepository {
  final DioClient _dioClient = getIt<DioClient>();

  Future<List<OSMDataCentroid>> getMarinasCentroidsByName(String name) {
    return _dioClient.dio
        .get(
            "${AppUrls.baseUrl}${AppUrls.tile}/osm/polygon/marinas/centroids/$name")
        .asStream()
        .map((Response<dynamic> event) => (event.data as List)
            .map((e) => OSMDataCentroid.fromJson(e))
            .toList())
        .single;
  }
}
