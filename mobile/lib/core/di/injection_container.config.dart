// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../app/router/app_router.dart' as _i180;
import '../network/api_client.dart' as _i557;
import '../storage/cookie_storage_service.dart' as _i916;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i180.AppRouter>(() => _i180.AppRouter());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i916.CookieStorageService>(
        () => _i916.CookieStorageService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingletonAsync<_i557.ApiClient>(
        () => _i557.ApiClient.create(gh<_i916.CookieStorageService>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
