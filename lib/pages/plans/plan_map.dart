import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpmobile/models/stage.dart';
import 'package:tpmobile/pages/plans/plan_summary_drawer.dart';

import '../../models/plan.dart';
import '../../services/setup_di.dart';
import '../../services/urls.dart';
import '../../services/util_service.dart';
import '../../utils/widgets/internet_authentication.dart';
import 'dart:math' as math;

class PlanMap extends StatefulWidget {
  final PlanWrapper plan;
  final OfflineRegionDefinition? offlineRegionDefinition;

  const PlanMap(
      {super.key, required this.offlineRegionDefinition, required this.plan});

  @override
  State<StatefulWidget> createState() => _PlanMapState();
}

class _PlanMapState extends State<PlanMap> {
  MaplibreMapController? _controller;
  UtilService utilService = getIt<UtilService>();
  BehaviorSubject<LatLng> userPosition = BehaviorSubject<LatLng>();
  BehaviorSubject<bool> cameraDismissed = BehaviorSubject<bool>();
  BehaviorSubject<bool> loading = BehaviorSubject<bool>();
  BehaviorSubject<Map<String, Map<String, dynamic>>> closestPoint =
      BehaviorSubject<Map<String, Map<String, dynamic>>>();
  final BehaviorSubject<Duration> duration = BehaviorSubject<Duration>();
  Timer? timer;
  final BehaviorSubject<int> _seconds = BehaviorSubject<int>();

  _PlanMapState();

  @override
  void initState() {
    super.initState();
    duration.add(const Duration());
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    const addSeconds = 1;
    _seconds.add(duration.value.inSeconds + addSeconds);
    duration.add(Duration(seconds: _seconds.value));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Plan navigation"),
        actions: [
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.timeline),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ))
        ],
      ),
      endDrawer:
          PlanSummaryDrawer(plan: widget.plan, closestPoint: closestPoint),
      body: Stack(children: [
        InternetAuthenticationChecker(
          internetFailing: offlineMap(),
          authenticatedWidget: authenticatedMap(),
        ),
        StreamBuilder(
            stream: userPosition.stream,
            builder: (context, snapshot) => Positioned(
                top: 30,
                left: 10,
                child: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Latitude: ${convertToDMS(snapshot.data?.latitude ?? 0, true)}\nLongitude: ${convertToDMS(snapshot.data?.longitude ?? 0, false)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ))))),
        StreamBuilder(
            stream: duration.stream,
            builder: (context, snapshot) => Positioned(
                top: 30,
                right: 60,
                child: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: buildTime()))))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => toCurrentLocation(),
        child: const Icon(Icons.gps_fixed),
      ));

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.value.inHours);
    final minutes = twoDigits(duration.value.inMinutes.remainder(60));
    final seconds = twoDigits(duration.value.inSeconds.remainder(60));
    return Text("$hours:$minutes:$seconds");
  }

  LatLng get _center {
    final bounds = widget.offlineRegionDefinition?.bounds ??
        LatLngBounds(
            southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
    final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }

  String convertToDMS(double coordinate, bool isLat) {
    double absolute = coordinate.abs();
    int degrees = absolute.floor();
    double minutesNotTruncated = (absolute - degrees) * 60;
    int minutes = minutesNotTruncated.floor();
    int seconds = ((minutesNotTruncated - minutes) * 60).floor();

    String compassCoordinate = "";

    if (isLat) {
      compassCoordinate = coordinate.ceil() > 0 ? "N" : "S";
    } else {
      compassCoordinate = coordinate.ceil() > 0 ? "E" : "W";
    }

    return '''${coordinate.ceil()}º $minutes' $seconds" $compassCoordinate''';
  }

  MaplibreMap authenticatedMap() => MaplibreMap(
      initialCameraPosition:
          const CameraPosition(target: LatLng(0, 0), zoom: 1),
      onMapCreated: (MaplibreMapController controller) =>
          onMapCreated(controller),
      myLocationEnabled: true,
      compassEnabled: true,
      styleString:
          "${AppUrls.baseUrl}${AppUrls.tile}/stage/style/${widget.plan.plan.id}.json",
      myLocationTrackingMode: MyLocationTrackingMode.Tracking,
      onUserLocationUpdated: (UserLocation location) {
        userPosition.add(location.position);
        calculateClosest();
      },
      onCameraTrackingChanged: (MyLocationTrackingMode mode) =>
          print("Mode-> ${mode.toString()}"),
      onCameraTrackingDismissed: () => print("dismissed"));

  MaplibreMap offlineMap() => MaplibreMap(
        initialCameraPosition: CameraPosition(
            target: _center,
            zoom: widget.offlineRegionDefinition?.minZoom ?? 0 + 4,
            tilt: 5),
        onMapCreated: (MaplibreMapController controller) =>
            onMapCreated(controller),
        myLocationEnabled: true,
        compassEnabled: true,
        onUserLocationUpdated: (UserLocation location) =>
            userPosition.add(location.position),
        myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
        onCameraTrackingDismissed: () => cameraDismissed.add(true),
        minMaxZoomPreference: MinMaxZoomPreference(
            widget.offlineRegionDefinition?.minZoom,
            widget.offlineRegionDefinition?.maxZoom),
        styleString: widget.offlineRegionDefinition?.mapStyleUrl,
      );

  void onMapCreated(MaplibreMapController controller) {
    _controller = controller;
    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => toCurrentLocation());
  }

  void toCurrentLocation() {
    _controller?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
                userPosition.value.latitude, userPosition.value.longitude),
            zoom: 16,
            tilt: 50)),
        duration: const Duration(seconds: 1));
  }

  void calculateClosest() {
    final result = widget.plan.summaries.map((StageSummaryFullWrapper ssfw) {
      final points = ssfw.points
          .asMap()
          .entries
          .map((MapEntry<int, StagePointsSummary> e) => {
                'distance':
                    calculateDistance(e.value.point, userPosition.value),
                'index': e.key
              })
          .toList();
      points.sort((first, second) =>
          first['distance']?.compareTo(second['distance']!) ?? 0);

      return {
        'stage_summary': ssfw.summary.toJson(),
        'closest_point': points.first
      };
    }).toList();
    closestPoint.add(result.first);
  }

  double calculateDistance(GeoJSONPoint point, LatLng currentLocation) {
    LatLng pointLatLng = LatLng(point.coordinates[1], point.coordinates[0]);

    double latRad = degreeToRadian(pointLatLng.latitude);
    double longRad = degreeToRadian(pointLatLng.longitude);

    double currentLatRad = degreeToRadian(currentLocation.latitude);
    double currentLongRad = degreeToRadian(currentLocation.longitude);

    double deltaLong = currentLongRad - longRad;
    double deltaLat = currentLatRad - latRad;

    double a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(latRad) *
            math.cos(currentLatRad) *
            math.pow(math.sin(deltaLong / 2), 2);

    double c = 2 * math.asin(math.sqrt(a));

    double km = 6371 * c;

    return km;
  }

  double degreeToRadian(double degree) => degree * math.pi / 180;
}
