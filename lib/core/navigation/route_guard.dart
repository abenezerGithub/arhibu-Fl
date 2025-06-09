import 'package:arhibu/core/routes/route_names.dart';
import 'package:flutter/material.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;

  const RouteGuard({Key? key, required this.child, this.requiresAuth = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for authentication logic
    final isAuthenticated = false; // Replace with your own logic

    if (requiresAuth && !isAuthenticated) {
      // Redirect to login if trying to access protected route while not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!requiresAuth && isAuthenticated) {
      // Redirect to home if trying to access auth routes while authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}

// Removed BlocBuilder<AuthBloc, AuthState> and all AuthState checks.
// You can implement your own route guard logic here if needed, or simply return the child widget.
Widget routeGuard({required Widget child}) {
  // For now, just return the child directly (no auth check)
  return child;
}
