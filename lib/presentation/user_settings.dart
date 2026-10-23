import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/presentation/appView.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(
            context,
          ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AppView()), (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Impostazioni Utente')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface),
                  side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.onSurface)),
                ),
                child: Text("Logout", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ),
          ],
        ),
        //TODO: Implementare Eliminazione account con Bloc
      ),
    );
  }
}
