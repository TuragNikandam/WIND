import 'package:andromeda_app/controllers/registration/registration_controller.dart';
import 'package:andromeda_app/controllers/registration/registration_step1_controller.dart';
import 'package:andromeda_app/controllers/registration/registration_step2_controller.dart';
import 'package:andromeda_app/controllers/registration/registration_step3_controller.dart';
import 'package:andromeda_app/models/user_model.dart';
import 'package:andromeda_app/services/base_service.dart';
import 'package:andromeda_app/services/discussion_service.dart';
import 'package:andromeda_app/services/master_data_service.dart';
import 'package:andromeda_app/services/navigation_service.dart';
import 'package:andromeda_app/services/news_service.dart';
import 'package:andromeda_app/services/user_service.dart';
import 'package:andromeda_app/services/voting_service.dart';
import 'package:andromeda_app/views/guests/guest_main_view.dart';
import 'package:andromeda_app/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:andromeda_app/controllers/login_controller.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<BaseService>(create: (_) => BaseService()),
          ProxyProvider<BaseService, UserService>(
            update: (_, baseService, userService) => UserService(baseService),
          ),
          ProxyProvider<BaseService, MasterDataService>(
            update: (_, baseService, masterdataService) =>
                MasterDataService(baseService),
          ),
          ProxyProvider<BaseService, VotingService>(
            update: (_, baseService, votingService) =>
                VotingService(baseService),
          ),
          ProxyProvider<BaseService, NewsService>(
            update: (_, baseService, newsService) => NewsService(baseService),
          ),
          ProxyProvider<BaseService, DiscussionService>(
            update: (_, baseService, discussionService) =>
                DiscussionService(baseService),
          ),
          ChangeNotifierProvider<User>(create: (_) => User()),
          Provider<NavigationService>(create: (_) => NavigationService()),
          // ... other providers ...
        ],
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const secondaryColor = Color.fromARGB(255, 167, 107, 86);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projekt Andromeda',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const LoginController(),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        final routes = <String, WidgetBuilder>{
          '/login': (ctx) => const LoginController(),
          '/registration': (ctx) => const RegistrationController(),
          '/registration_step1': (ctx) => const RegistrationStep1Controller(),
          '/registration_step2': (ctx) => const RegistrationStep2Controller(),
          '/registration_step3': (ctx) => const RegistrationStep3Controller(),
          MainView.route: (ctx) => const MainView(),
          GuestMainView.route: (ctx) => const GuestMainView(),
          // Add more routes here...
        };

        builder = routes[settings.name]!;

        return PageRouteBuilder(
          pageBuilder: (ctx, animation, secondaryAnimation) => builder(ctx),
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: RouteSettings(
            name: settings.name,
            arguments: settings.arguments,
          ),
        );
      },
    );
  }
}
