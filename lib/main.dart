import 'package:flutter/material.dart';
import 'package:get_boilerplate/src/lang/translation_service.dart';
import 'package:get_boilerplate/src/routes/app_pages.dart';
import 'package:get_boilerplate/src/shared/logger/logger_utils.dart';
import 'package:get_boilerplate/src/theme/theme_service.dart';
import 'package:get_boilerplate/src/theme/themes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,
      themeMode: ThemeService().getThemeMode(),
    );
  }
}
