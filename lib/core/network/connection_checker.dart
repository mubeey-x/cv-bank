import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  /// True when a request to the backend is likely to succeed.
  Future<bool> get isConnected;

  /// Emits on every change. Drives the offline banner.
  Stream<bool> get onStatusChange;

  void dispose();
}

class ConnectionCheckerImpl implements ConnectionChecker {
  ConnectionCheckerImpl({
    required this._connectivity,
    required this._internet,
  }) {
    _sub = _internet.onStatusChange.listen(
      (status) => _update(status == InternetStatus.connected),
    );
  }

  final Connectivity _connectivity;
  final InternetConnection _internet;

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<InternetStatus>? _sub;

  static const _ttl = Duration(seconds: 3);
  bool? _cached;
  DateTime? _cachedAt;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> get isConnected async {
    final cachedAt = _cachedAt;
    if (_cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _ttl) {
      return _cached!;
    }

    // Cheap negative first. No interface at all means there is no
    // point paying for a round trip.
    final interfaces = await _connectivity.checkConnectivity();
    final hasInterface = interfaces.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) {
      _update(false);
      return false;
    }

    // Interface exists, which on mobile data proves nothing. Actually
    // reach out.
    final reachable = await _internet.hasInternetAccess;
    _update(reachable);
    return reachable;
  }

  void _update(bool value) {
    _cached = value;
    _cachedAt = DateTime.now();
    if (!_controller.isClosed) _controller.add(value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
