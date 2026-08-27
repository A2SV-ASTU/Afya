import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../core/storage/secure_storage_service.dart';
import 'route_paths.dart';

@lazySingleton
class RouteGuards {
  final SecureStorageService _secureStorage;

  RouteGuards(this._secureStorage);

  Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final refreshToken = await _secureStorage.getRefreshToken();
    final isAuthenticated = refreshToken != null;
    final isAuthRoute = state.matchedLocation == RoutePaths.signIn ||
                        state.matchedLocation == RoutePaths.signUp ||
                        state.matchedLocation == RoutePaths.splash;

    if (!isAuthenticated && !isAuthRoute && !state.matchedLocation.startsWith('/access-requests/')) {
      return RoutePaths.signIn;
    }

    if (isAuthenticated && isAuthRoute) {
      return RoutePaths.dashboard;
    }

    return null;
  }
}
