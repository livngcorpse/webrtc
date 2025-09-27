// lib/src/routes/app_pages.dart
import 'package:get_boilerplate/src/pages/auth/login_page.dart';
import 'package:get_boilerplate/src/pages/auth/register_page.dart';
import 'package:get_boilerplate/src/pages/dashboard/dashboard_page.dart';
import 'package:get_boilerplate/src/pages/meeting/create_meeting_page.dart';
import 'package:get_boilerplate/src/pages/meeting/join_meeting_page.dart';
import 'package:get_boilerplate/src/pages/meeting/meeting_details_page.dart';
import 'package:get_boilerplate/src/pages/home/home_page.dart';
import 'package:get_boilerplate/src/middleware/auth_middleware.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // Auth routes
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),

    // Protected routes
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardPage(),
      middlewares: [AuthMiddleware()],
    ),

    // Meeting routes
    GetPage(
      name: Routes.CREATE_MEETING,
      page: () => const CreateMeetingPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.JOIN_MEETING,
      page: () => const JoinMeetingPage(),
    ),
    GetPage(
      name: Routes.MEETING_DETAILS,
      page: () => const MeetingDetailsPage(),
    ),
    GetPage(
      name: Routes.MEETING_ROOM,
      page: () => const HomePage(), // This is your video call page
    ),
  ];
}
