part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final RecordModel user;
  const Authenticated({required this.user});
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});
}

// Nuovo stato per confermare l'invio della mail di reset
class PasswordResetSent extends AuthState {
  final String message;
  const PasswordResetSent({required this.message});
}
