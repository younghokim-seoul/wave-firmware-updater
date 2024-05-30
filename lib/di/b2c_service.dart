import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

final _locator = GetIt.asNewInstance();


T getService<T extends Object>({String? id}) => _locator<T>(instanceName: id);


T? tryGetService<T extends Object>({String? id}) {
  return hasService<T>(id: id) ? getService<T>(id: id) : null;
}

T createService<T extends Object>(dynamic param, {String? id}) {
  return _locator<T>(param1: param, instanceName: id);
}

T? tryCreateService<T extends Object>(dynamic param, {String? id}) {
  return hasService<T>(id: id) ? createService<T>(param, id: id) : null;
}

bool hasService<T extends Object>({String? id}) {
  return _locator.isRegistered<T>(instanceName: id);
}

void registerService<T extends Object>(
    T Function() create, {
      String? id,
      FutureOr<void> Function(T service)? dispose,
    }) {
  _locator.registerLazySingleton<T>(create, dispose: dispose, instanceName: id);
}

void tryRegisterService<T extends Object>(
    T Function() create, {
      String? id,
      FutureOr<void> Function(T service)? dispose,
    }) {
  if (!hasService<T>(id: id)) {
    registerService<T>(create, id: id, dispose: dispose);
  }
}

void resetService<T extends Object>({
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  _locator.resetLazySingleton<T>(instanceName: id, disposingFunction: dispose);
}

Future<void> resetAllServices() => _locator.reset();

void registerServiceInstance<T extends Object>(T service, {String? id}) {
  _locator.registerSingleton<T>(service, instanceName: id);
}

void tryRegisterServiceInstance<T extends Object>(T service, {String? id}) {
  if (!hasService<T>(id: id)) {
    registerServiceInstance<T>(service, id: id);
  }
}

void registerServiceFactory<T extends Object>(
    T Function(dynamic param) create, {
      String? id,
    }) {
  _locator.registerFactoryParam<T, Object?, Object?>(
        (param, _) => create(param),
    instanceName: id,
  );
}

void tryRegisterServiceFactory<T extends Object>(
    T Function(dynamic param) create, {
      String? id,
    }) {
  if (!hasService<T>(id: id)) {
    registerServiceFactory<T>(create, id: id);
  }
}

void unregisterService<T extends Object>({
  String? id,
  FutureOr<void> Function(T service)? dispose,
}) {
  if (hasService<T>(id: id)) {
    _locator.unregister<T>(instanceName: id, disposingFunction: dispose);
  }
}

/// Registers a mock service for testing purposes.
@visibleForTesting
void registerMockService<T extends Object>(T mock, {String? id}) {
  unregisterService<T>(id: id);
  registerServiceInstance<T>(mock);
}

/// Unregisters a mock service for testing purposes.
@visibleForTesting
void unregisterMockService<T extends Object>({String? id}) {
  unregisterService<T>(id: id);
}
