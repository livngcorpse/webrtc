import 'package:get_boilerplate/src/app.dart';
import 'package:get_boilerplate/src/pages/home/home_page.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ROOT;

  static final routes = [
    GetPage(
      name: Routes.ROOT,
      page: () => const App(),
      children: [
        GetPage(
          name: Routes.HOME,
          page: () => const HomePage(),
        ),
      ],
    ),
  ];
}
