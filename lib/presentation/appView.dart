import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/presentation/login_screen.dart';
import 'package:campo_base/presentation/mainScreen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}
