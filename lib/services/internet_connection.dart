import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class InternetConnectionService {
  final BehaviorSubject<bool> _connectionStatus = BehaviorSubject<bool>();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  Stream<bool> get connectionStream => _connectionStatus.stream;
  bool get connectionsStatus => _connectionStatus.value;

  InternetConnectionService() {
    _connectivity
        .checkConnectivity()
        .then(_updateConnectivityStatus)
        .catchError((onError) => print(onError));
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  void _updateConnectivityStatus(ConnectivityResult result) async {
    _connectionStatus.add(_evaluateConnection(result));
  }

  bool _evaluateConnection(ConnectivityResult result) =>
      result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;

  void dispose() {
    _subscription.cancel();
  }
}
