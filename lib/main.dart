import 'bootstrap.dart';
import 'config/app_environment.dart';

Future<void> main() async {
  const flavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');
  await bootstrap(flavor: AppFlavor.fromString(flavor));
}
