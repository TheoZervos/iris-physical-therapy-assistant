import 'package:get_it/get_it.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // We register it as a singleton so everyone shares the same state
  getIt.registerLazySingleton<AppStateViewModel>(() => AppStateViewModel());
}