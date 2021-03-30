import 'package:flutter/widgets.dart';
import 'package:tada_messenger/presentation/pages/login_page.dart';
import 'package:tada_messenger/presentation/pages/room_page.dart';
import 'package:tada_messenger/presentation/pages/rooms_page.dart';

class AppRoutes {
  static const String login = 'login';
  static const String rooms = 'rooms';
  static const String room = 'room';
}

class AppRouteGenerator {
  static const roomArgument = 'room';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    Map<String, dynamic> arguments;
    if (settings.arguments is Map<String, dynamic>) {
      arguments = settings.arguments as Map<String, dynamic>;
    } else {
      arguments = {};
    }

    switch (routeName) {
      case AppRoutes.login:
        return LoginPage.route(
          settings: settings,
        );
      case AppRoutes.rooms:
        return RoomsPage.route(
          settings: settings,
        );
      case AppRoutes.room:
        return RoomPage.route(
          room: arguments[roomArgument],
          settings: settings,
        );
      default:
        throw Exception('Undefined route: $routeName');
    }
  }
}
