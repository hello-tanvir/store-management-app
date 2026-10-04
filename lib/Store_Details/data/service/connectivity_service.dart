import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance =
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
  _subscription;

  Future<void> startListening() async {
    final result = await _connectivity.checkConnectivity();

    await _handleConnectivity(result);

    _subscription =
        _connectivity.onConnectivityChanged.listen(
          _handleConnectivity,
        );
  }

  Future<void> _handleConnectivity(
      List<ConnectivityResult> results,
      ) async {
    final hasInternetConnection =
    results.any(
          (result) =>
      result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (!hasInternetConnection) {
      return;
    }

    await SyncService.instance.syncStores();
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}