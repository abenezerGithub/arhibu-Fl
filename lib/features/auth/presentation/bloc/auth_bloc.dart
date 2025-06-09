
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
//to be implemented if firebase works
class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}
