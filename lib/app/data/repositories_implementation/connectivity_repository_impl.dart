import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/connectivity_repository.dart';
import '../services/remote/internet_checker.dart';

class ConnectivityRepositoryImpl extends ConnectivityRepository {
  final Connectivity _connectivity;
  final InternetChecker _internetChecker;

  ConnectivityRepositoryImpl(this._connectivity,
      this._internetChecker,);

  @override
  Future<bool> get hasInternet async {
    final connectivityResult = await (_connectivity.checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return _internetChecker.hasInternet();
  }
}
