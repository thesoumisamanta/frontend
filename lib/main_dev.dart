import 'bootstrap.dart';
import 'config/app_environment.dart';

Future<void> main() async {
  await bootstrap(flavor: AppFlavor.dev);
}
