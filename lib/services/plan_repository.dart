import 'package:dio/dio.dart';
import 'package:tpmobile/models/plan.dart';
import 'package:tpmobile/services/setup_di.dart';
import 'package:tpmobile/services/urls.dart';
import 'package:tpmobile/utils/dio/dio_client.dart';

import '../models/stage.dart';

class PlansRepository {
  final DioClient _dioClient = getIt<DioClient>();

  Future<List<Plan>> getMyPlans() => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.cms}/plan/myteamplans")
      .asStream()
      .map((Response<dynamic> event) =>
          (event.data as List).map((e) => Plan.fromJson(e)).toList())
      .single;

  Future<List<PlanWrapper>> getPlansFullSummary() => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.tile}/stage/plans/full/summary")
      .asStream()
      .map((Response<dynamic> event) =>
          (event.data as List).map((e) => PlanWrapper.fromJson(e)).toList())
      .single;

  Future<List<StageSummaryWrapper>> getStageSummary(int planId) =>
      _dioClient.dio
          .get("${AppUrls.baseUrl}${AppUrls.tile}/stage/summary/mobile/$planId")
          .asStream()
          .map((Response<dynamic> event) => (event.data as List)
              .map((e) => StageSummaryWrapper.fromJson(e))
              .toList())
          .single;

  Future<StageBounds?> getStagesBounds(int planId) => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.tile}/stage/bounds/$planId")
      .asStream()
      .map((event) => StageBounds.fromJson(event.data))
      .single;

  Future getGPX(int planId, ProgressCallback onDownloadProgress) =>
      _dioClient.dio.get("${AppUrls.baseUrl}${AppUrls.tile}/stage/gpx/$planId",
          onReceiveProgress: onDownloadProgress,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500));

  Future getPDF(int planId, ProgressCallback onDownloadProgress) =>
      _dioClient.dio.get("${AppUrls.baseUrl}${AppUrls.tile}/stage/pdf/$planId",
          onReceiveProgress: onDownloadProgress,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status! < 500));

  Future startPlan(int planId) => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.tile}/stage/start/plan/$planId");

  Future endStage(int stageId) => _dioClient.dio
      .get("${AppUrls.baseUrl}${AppUrls.tile}/stage/finish/$stageId");
}
