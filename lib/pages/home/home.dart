import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpmobile/services/setup_di.dart';
import 'package:tpmobile/services/urls.dart';
import 'package:tpmobile/services/util_service.dart';

import '../../models/osm_data.dart';
import '../../services/notification_service.dart';
import '../../utils/widgets/navigation_drawer/navigation_drawer.dart';
import '../../utils/widgets/overlay_loader.dart';
import '../../utils/widgets/search_bar/search_delegate.dart';

class HomePage extends StatefulWidget {
  static String route = "home";

  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MaplibreMapController? _controller;
  LatLng? location;
  bool loading = false;
  NotificationService notificationService = getIt<NotificationService>();
  BehaviorSubject<LatLng> userPosition = BehaviorSubject<LatLng>();

  void _onMapCreated(MaplibreMapController controller) {
    _controller = controller;
    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => toCurrentLocation());
    _controller?.onFeatureTapped
        .add((dynamic id, Point<double> point, LatLng coordinates) {
      print("feature");
      print(id);
      print(point);
      print(coordinates);
    });
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

  Future<void> notification() async {
    await notificationService.showNotification(
        title: "Notification", body: "Downloaded file");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travelling planner"),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: MySearchDelegate())
                    .then((value) {
                  if (value != null) {
                    OSMDataCentroid osmCentroid = (value as OSMDataCentroid);
                    _controller?.animateCamera(CameraUpdate.zoomTo(5)).then(
                        (value) => _controller?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                                LatLng(osmCentroid.y, osmCentroid.x), 15),
                            duration: const Duration(seconds: 4)));
                  }
                });
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: const MyNavigationDrawer(),
      body: Stack(children: [
        MaplibreMap(
            initialCameraPosition:
                const CameraPosition(target: LatLng(0, 0), zoom: 1),
            onMapCreated: _onMapCreated,
            styleString:
                "${AppUrls.baseUrl}${AppUrls.tile}/stage/style/home/home.json",
            myLocationEnabled: true,
            compassEnabled: true,
            onCameraTrackingChanged: (track) => print("changed"),
            onCameraTrackingDismissed: () => print("dismissed"),
            trackCameraPosition: true,
            onUserLocationUpdated: (UserLocation location) {
              userPosition.add(location.position);

              _controller?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: location.position,
                      zoom: 16,
                      tilt: 50,
                      bearing: location.bearing ?? 0)));
            },
            myLocationTrackingMode: MyLocationTrackingMode.Tracking),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => toCurrentLocation(),
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }
}
