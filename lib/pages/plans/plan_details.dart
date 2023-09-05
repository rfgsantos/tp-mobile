import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timelines/timelines.dart';
import 'package:tpmobile/pages/plans/plan_map.dart';
import 'package:tpmobile/pages/plans/plan_marina_view.dart';
import 'package:tpmobile/pages/teams/forms/team_view.dart';
import 'package:tpmobile/services/notification_service.dart';

import '../../models/plan.dart';
import '../../models/stage.dart';
import '../../models/team.dart';
import '../../models/weather.dart';
import '../../services/plan_repository.dart';
import '../../services/setup_di.dart';
import '../../services/urls.dart';
import '../../utils/widgets/confirmation_dialog.dart';
import '../../utils/widgets/overlay_loader.dart';

class PlanDetails extends StatefulWidget {
  final PlanWrapper planWrapper;

  const PlanDetails({super.key, required this.planWrapper});

  @override
  State<StatefulWidget> createState() => _PlanDetailsState();
}

class _PlanDetailsState extends State<PlanDetails> {
  final BehaviorSubject<bool> _loading = BehaviorSubject<bool>();
  final BehaviorSubject<double> _downloadProgress = BehaviorSubject<double>();
  final PlansRepository _plansRepository = getIt<PlansRepository>();
  final NotificationService _notificationService = getIt<NotificationService>();

  @override
  void initState() {
    super.initState();
    _loading.sink.add(false);
    _downloadProgress.sink.add(0.0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Plan Details"),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      child: RichText(
                          text: const TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                              Icons.download,
                              color: Colors.black,
                            ),
                            alignment: PlaceholderAlignment.middle),
                        TextSpan(text: ".GPX")
                      ], style: TextStyle(color: Colors.black))),
                      onTap: () => _downloadGPX(),
                    ),
                    PopupMenuItem(
                      child: RichText(
                          text: const TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                              Icons.download,
                              color: Colors.black,
                            ),
                            alignment: PlaceholderAlignment.middle),
                        TextSpan(text: ".PDF")
                      ], style: TextStyle(color: Colors.black))),
                      onTap: () => _downloadPDF(),
                    ),
                    PopupMenuItem(
                        child: RichText(
                            text: const TextSpan(children: [
                      WidgetSpan(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          alignment: PlaceholderAlignment.middle),
                      TextSpan(text: "Delete")
                    ], style: TextStyle(color: Colors.red))))
                  ])
        ],
      ),
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                _PlanImage(plan: widget.planWrapper.plan),
                const SizedBox(height: 12),
                _PlanDetails(plan: widget.planWrapper.plan),
                const SizedBox(height: 12),
                _PlanDates(plan: widget.planWrapper.plan),
                const SizedBox(height: 12),
                _PlanTeamDetails(plan: widget.planWrapper.plan),
                const SizedBox(height: 20),
                _PlanWeatherDetails(
                    summaryWeatherWrapper: widget.planWrapper.summaries),
                const SizedBox(height: 20),
                _PlanStageSummary(
                    plan: widget.planWrapper.plan,
                    summary: widget.planWrapper.summaries),
                const SizedBox(height: 40),
                _PlanActions(
                    plan: widget.planWrapper,
                    summary: widget.planWrapper.summaries,
                    loading: _loading,
                    downloadProgress: _downloadProgress)
              ]))),
          _PlanLoader(downloadProgress: _downloadProgress, loading: _loading)
        ],
      ));

  void _progressDownload(int received, int total) {
    if (total != -1) {
      _downloadProgress.sink.add(received / total * 100);
    }
  }

  void _downloadGPX() async {
    _loading.sink.add(true);
    Response response = await _plansRepository.getGPX(
        widget.planWrapper.plan.id ?? 0, _progressDownload);
    _loading.sink.add(false);
    await FileSaver.instance.saveFile(
        "${widget.planWrapper.plan.name}-${widget.planWrapper.plan.team.name}-${widget.planWrapper.plan.start_date.toString()}",
        response.data,
        "gpx",
        mimeType: MimeType.OTHER);
  }

  void _downloadPDF() async {
    _loading.sink.add(true);
    Response response = await _plansRepository.getPDF(
        widget.planWrapper.plan.id ?? 0, _progressDownload);
    _loading.sink.add(false);

    String fileName =
        "${widget.planWrapper.plan.name}-${widget.planWrapper.plan.team.name}-${DateFormat.yMMMMd().format(widget.planWrapper.plan.start_date)}";

    String filePath = await FileSaver.instance
        .saveFile(fileName, response.data, "pdf", mimeType: MimeType.PDF);

    await _notificationService.showNotification(
        title: 'File downloaded successfully',
        body: '$fileName.pdf',
        payload: filePath);
  }
}

class _PlanImage extends StatelessWidget {
  final Plan plan;

  const _PlanImage({required this.plan});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 300,
      child: plan.image != null
          ? Image.memory(const Base64Decoder().convert(plan.image ?? ""))
          : Image.asset("assets/xmarksthespot.png"));
}

class _PlanDetails extends StatelessWidget {
  final Plan plan;

  const _PlanDetails({required this.plan});

  @override
  Widget build(BuildContext context) => Column(children: [
        TextFormField(
            enabled: false,
            initialValue: plan.name,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Name',
            )),
        TextFormField(
            enabled: false,
            initialValue: plan.description,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Description',
            )),
        TextFormField(
            enabled: false,
            initialValue: plan.state,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'State',
            ))
      ]);
}

class _PlanDates extends StatelessWidget {
  final Plan plan;

  const _PlanDates({required this.plan});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: TextFormField(
                initialValue: DateFormat.yMMMMd().format(plan.start_date),
                decoration: const InputDecoration(
                    border: InputBorder.none, labelText: 'Start date'))),
        Expanded(
            child: TextFormField(
                initialValue: DateFormat.yMMMMd().format(plan.arrival_date),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Arrival date',
                )))
      ]);
}

class _PlanTeamDetails extends StatelessWidget {
  final Plan plan;

  const _PlanTeamDetails({required this.plan});

  static Route<void> _viewTeamDialogRoute(context, arguments) {
    return MaterialPageRoute(
        builder: (context) => TeamView(team: Team.fromJson(arguments)),
        fullscreenDialog: true);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        InkWell(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: "Team: ${plan.team.name}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Colors.lightBlueAccent)),
            const WidgetSpan(
                child: Icon(
              Icons.open_in_new,
              size: 20,
              color: Colors.lightBlueAccent,
            ))
          ])),
          onTap: () => Navigator.restorablePush<void>(
              context, _viewTeamDialogRoute,
              arguments: plan.team.toJson()),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: plan.team.members
                .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: e.user?.profile_image != null
                          ? Image.memory(const Base64Decoder()
                                  .convert(e.user?.profile_image ?? ""))
                              .image
                          : Image.asset("assets/avatar.png").image,
                    )))
                .toList())
      ]);
}

class _PlanWeatherDetails extends StatelessWidget {
  final List<StageSummaryFullWrapper> summaryWeatherWrapper;

  const _PlanWeatherDetails({required this.summaryWeatherWrapper});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...summaryWeatherWrapper
            .map((StageSummaryFullWrapper e) => DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Expanded(child: Text('H'))),
                  DataColumn(label: Expanded(child: Text('T'))),
                  DataColumn(label: Expanded(child: Text('WS'))),
                  DataColumn(label: Expanded(child: Text('WD'))),
                  DataColumn(label: Expanded(child: Text('RR')))
                ],
                rows: e.summary.weather
                        ?.map((Weather e) => DataRow(cells: [
                              DataCell(Text(
                                "${e.start_hour}-${e.end_hour}",
                                textAlign: TextAlign.start,
                              )),
                              DataCell(Text("${e.min_temp}-${e.max_temp}")),
                              DataCell(Text(
                                  "${e.min_wind_speed}-${e.max_wind_speed}")),
                              DataCell(Text(
                                  "${e.min_wind_direction}-${e.max_wind_direction}")),
                              DataCell(
                                  Text("${e.min_rain_risk}-${e.max_rain_risk}"))
                            ]))
                        .toList() ??
                    []))
            .toList(),
        summaryWeatherWrapper
                .where(
                    (element) => element.summary.weather?.isNotEmpty ?? false)
                .isEmpty
            ? Container()
            : RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    text: "H",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: " - Hours, ",
                          style: DefaultTextStyle.of(context).style),
                      const TextSpan(
                          text: "T",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " - Temperature ºC, ",
                          style: DefaultTextStyle.of(context).style),
                      const TextSpan(
                          text: "WS",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " - Wind speed km/h, ",
                          style: DefaultTextStyle.of(context).style),
                      const TextSpan(
                          text: "WD",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " - Wind direction º, ",
                          style: DefaultTextStyle.of(context).style),
                      const TextSpan(
                          text: "RR",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: " - Rain risk mm ",
                          style: DefaultTextStyle.of(context).style),
                    ]))
      ]);
}

class _PlanStageSummary extends StatelessWidget {
  final Plan plan;
  final List<StageSummaryFullWrapper> summary;

  const _PlanStageSummary({required this.plan, required this.summary});

  String getFormattedTime(double timeInHours) {
    int hours = timeInHours.floor();
    double minutesRest = timeInHours % hours;
    int minutes = minutesRest.isNaN
        ? (timeInHours * 60).floor()
        : (minutesRest * 60).floor();
    return "$hours h $minutes m";
  }

  void showMapView(GeoJSONPoint? point, BuildContext context) {
    LatLng center =
        LatLng(point?.coordinates[1] ?? 0, point?.coordinates[0] ?? 0);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: false,
              content: PlanMarinaView(center: center),
            ));
  }

  Widget _evaluateIndex(
          int index, List<StageSummaryFullWrapper> summary, BuildContext _) =>
      index == 1
          ? InkWell(
              child: Text(summary[0].summary.summary?.ending_marina ?? '',
                  style: const TextStyle(decoration: TextDecoration.underline)),
              onTap: () =>
                  showMapView(summary[0].summary.summary?.ending_centroid, _),
            )
          : index != summary.length &&
                  summary[index].summary.summary?.starting_marina != null
              ? InkWell(
                  child: Text(
                      summary[index].summary.summary?.starting_marina ?? '',
                      style: const TextStyle(
                          decoration: TextDecoration.underline)),
                  onTap: () => showMapView(
                      summary[index].summary.summary?.starting_centroid, _),
                )
              : InkWell(
                  child: Text(
                      summary[index - 1].summary.summary?.ending_marina ?? '',
                      style: const TextStyle(
                          decoration: TextDecoration.underline)),
                  onTap: () => showMapView(
                      summary[index - 1].summary.summary?.ending_centroid, _),
                );

  @override
  Widget build(BuildContext context) => summary.isNotEmpty
      ? FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            indicatorTheme: const IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 4,
            ),
          ),
          builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemCount: summary.length + 1,
              contentsBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _evaluateIndex(index, summary, _),
                        index == summary.length
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(getFormattedTime(
                                    summary[index].summary.summary?.time ?? 0)),
                              )
                      ])),
              connectorBuilder: (_, index, __) =>
                  const SolidLineConnector(color: Color(0xff6ad192)),
              indicatorBuilder: (_, index) => const DotIndicator(
                    color: Color(0xff6ad192),
                  )),
        )
      : const Center(
          child: Text(
              "You don't have stages prepared. Access web browser to plan."));
}

class _PlanActions extends StatelessWidget {
  final PlanWrapper plan;
  final BehaviorSubject<bool> loading;
  final BehaviorSubject<double> downloadProgress;
  final List<StageSummaryFullWrapper> summary;
  final PlansRepository _plansRepository = getIt<PlansRepository>();
  final BehaviorSubject<bool> _downloadedState = BehaviorSubject<bool>();

  _PlanActions(
      {required this.plan,
      required this.loading,
      required this.summary,
      required this.downloadProgress}) {
    _downloadedState.add(false);
    _getDownloadedState().then((value) => _downloadedState.add(value));
  }

  void _downloadOfflineTiles() async {
    final points = await _plansRepository.getStagesBounds(plan.plan.id ?? 0);
    final bounds = LatLngBounds(
        southwest: LatLng(points?.southwest.coordinates[1] ?? 0,
            points?.southwest.coordinates[0] ?? 0),
        northeast: LatLng(points?.northeast.coordinates[1] ?? 0,
            points?.northeast.coordinates[0] ?? 0));

    final regionDefinition = OfflineRegionDefinition(
        bounds: bounds,
        mapStyleUrl:
            "${AppUrls.baseUrl}${AppUrls.tile}/stage/style/${plan.plan.id}.json",
        minZoom: 6,
        maxZoom: 14);

    loading.sink.add(true);

    await setOfflineTileCountLimit(12000); // test
    downloadOfflineRegion(regionDefinition,
        metadata: {
          'planId': "${plan.plan.id}",
          'plan': plan.toJson(),
          'summary': summary.map((e) => e.toJson()).toList()
        },
        onEvent: _onDownloadEvent);
  }

  void _onDownloadEvent(DownloadRegionStatus status) {
    if (status is Success) {
      loading.sink.add(false);
      downloadProgress.sink.add(0);
    } else if (status is Error) {
      loading.sink.add(false);
    } else if (status is InProgress) {
      downloadProgress.sink.add(status.progress.floorToDouble());
    }
  }

  void _removeOfflineRegion() async {
    final offLineRegions = await getListOfRegions();
    if (offLineRegions.isNotEmpty) {
      final offLineRegion = offLineRegions
          .where((element) => element.metadata['planId'] == "${plan.plan.id}");
      if (offLineRegion.isNotEmpty) {
        await deleteOfflineRegion(offLineRegion.first.id);
        _downloadedState.add(false);
      }
    }
  }

  Future<bool> _getDownloadedState() async {
    bool? state = false;

    final regions = await getListOfRegions();
    final currentRegion = regions.where(
        (element) => int.parse(element.metadata['planId']) == plan.plan.id);

    if (currentRegion.isNotEmpty) {
      final Plan currentPlan =
          Plan.fromJson(currentRegion.first.metadata['plan']['plan']);
      if (currentPlan.updated_at != null) {
        state = currentPlan.updated_at
            ?.isAtSameMomentAs(plan.plan.updated_at ?? DateTime.now());
      }
    }
    return Future.value(state);
  }

  Future<void> startPlan(BuildContext context) async {
    final bool choice =
        await dialog(context, message: "Start navigating?") ?? false;

    if (choice) {
      final offLineRegions = await getListOfRegions();
      final offLineRegion = offLineRegions
          .where((element) => element.metadata['planId'] == "${plan.plan.id}");
      final test = await _plansRepository.startPlan(plan.plan.id ?? 0);

      if (offLineRegion.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => PlanMap(
                offlineRegionDefinition: offLineRegion.first.definition,
                plan: plan)));
      } else {
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) =>
                PlanMap(offlineRegionDefinition: null, plan: plan)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            StreamBuilder(
                stream: _downloadedState.stream,
                builder: (context, snapshot) => Switch(
                    value: snapshot.data ?? false,
                    onChanged: (bool change) => change
                        ? _downloadOfflineTiles()
                        : _removeOfflineRegion())),
            const Text("Download offline")
          ]),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async => startPlan(context),
                label: const Text("Start plan"),
                icon: const Icon(Icons.sailing),
              )),
        ],
      );
}

class _PlanLoader extends StatelessWidget {
  final BehaviorSubject<bool> loading;
  final BehaviorSubject<double> downloadProgress;
  final bool isFile;

  const _PlanLoader(
      {required this.loading,
      required this.downloadProgress,
      this.isFile = false});

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: loading.stream,
      builder: (context, snapshot) => snapshot.data ?? false
          ? StreamBuilder(
              stream: downloadProgress.stream,
              builder: (context, snapshot) => OverlayLoader(
                    message: isFile
                        ? "Downloading.."
                        : "Downloading ${snapshot.data}%",
                    value: snapshot.data ?? 0,
                  ))
          : Container());
}
