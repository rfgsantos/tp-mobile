import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:location/location.dart';

class UtilService {
  LatLng? location;

  UtilService();

  Future<LatLng> getCurrentPosition() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        this.location = null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        this.location = null;
      }
    }

    locationData = await location.getLocation();

    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}
