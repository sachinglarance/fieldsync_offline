import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityMonitor {
  Future<bool> isOnline();
  Stream<bool> get onStatusChange;
}

class PlatformConnectivityMonitor implements ConnectivityMonitor {
  PlatformConnectivityMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  static bool _hasNetwork(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();
}
