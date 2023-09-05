import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import '../../services/urls.dart';

class PlanMarinaView extends StatelessWidget {
  LatLng center;

  PlanMarinaView({super.key, required this.center});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 300,
      child: MaplibreMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 14),
        styleString:
            "${AppUrls.baseUrl}${AppUrls.tile}/stage/style/home/home.json",
      ));
}
