import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_environment.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (AppEnvironment.current.enableVerboseLogs) {
      print('onCreate -- ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (AppEnvironment.current.enableVerboseLogs) {
      print('onChange -- ${bloc.runtimeType}, $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (AppEnvironment.current.enableVerboseLogs) {
      print('onError -- ${bloc.runtimeType}, $error');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (AppEnvironment.current.enableVerboseLogs) {
      print('onClose -- ${bloc.runtimeType}');
    }
  }
}
