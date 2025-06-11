import 'package:arhibu/core/navigation/main_navigation.dart';
import 'package:arhibu/features/account_setup/presentation/screens/success_confirmation_screen.dart';
import 'package:arhibu/features/auth/presentation/bloc/login_bloc.dart';
import 'package:arhibu/features/auth/presentation/bloc/signup_bloc.dart';
import 'package:arhibu/features/auth/presentation/screens/getstarted_screen.dart';
import 'package:arhibu/features/auth/presentation/screens/login_screen.dart';
import 'package:arhibu/features/auth/presentation/screens/open_email_screen.dart';
import 'package:arhibu/features/auth/presentation/screens/signup_screen.dart';
import 'package:arhibu/features/auth/presentation/screens/verification_screen.dart';
import 'package:arhibu/features/chat/presentation/screens/chat_screen.dart';
import 'package:arhibu/features/home/domain/usecases/get_listings.dart';
import 'package:arhibu/features/home/presentation/bloc/listing_bloc.dart';
import 'package:arhibu/features/home/presentation/screens/home_page_screen.dart';
import 'package:arhibu/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:arhibu/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'route_names.dart';

class RouteBuilder {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      RouteNames.signup: (context) => BlocProvider(
            create: (context) => SignupBloc(),
            child: const SignupScreen(),
          ),
      RouteNames.login: (context) => BlocProvider(
            create: (context) => LoginBloc(),
            child: const LoginScreen(),
          ),

      RouteNames.getstarted: (context) => BlocProvider(
            create: (context) => LoginBloc(),
            child: const GetstartedScreen(),
          ),
      RouteNames.home: (context) => BlocProvider(
            create: (context) =>
                ListingBloc(RepositoryProvider.of<GetListings>(context)),
            child: MainNavigation(
              initialIndex: 0,
              child: const HomePageScreen(),
            ),
          ),

      RouteNames.openemail: (context) =>
          OpenEmailScreen(email: 'ziontaa9@example.com'),

      RouteNames.verify: (context) =>
          EmailVerificationScreen(email: 'ziontaa9@example.com'),

      RouteNames.chat: (context) =>
          MainNavigation(initialIndex: 1, child: const ChatScreen()),

      RouteNames.notifications: (context) => MainNavigation(
            initialIndex: 2,
            child: const NotificationsScreen(),
          ),
      // RouteNames.accountsetup:
      //     (context) => BlocProvider(
      //       create: (context) => AccountSetupBloc(),
      //       child: MainNavigation(initialIndex: 2, child: const AccountSetUp()),
      //     ),
      RouteNames.profile: (context) =>
          MainNavigation(initialIndex: 3, child: const ProfileScreen()),

      RouteNames.success: (context) => const SuccessConfirmationScreen(),
    };
  }
}
