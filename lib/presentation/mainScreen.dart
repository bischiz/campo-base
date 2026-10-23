import 'package:campo_base/bloc/deep_link/deep_link_bloc.dart';
import 'package:campo_base/bloc/eventi/eventi_bloc.dart';
import 'package:campo_base/bloc/notification/notification_bloc.dart';
import 'package:campo_base/presentation/eventiPage.dart';
import 'package:campo_base/presentation/evento_detail_page.dart';
import 'package:campo_base/presentation/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Schermata principale di Campo Base: elenco eventi (Passati / Futuri) con le impostazioni
/// in alto a destra. Gestisce anche l'apertura di un evento da notifica push o deep link.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationNavigationRequired) {
              if (state.navigationIntent == 'evento' && state.targetId != null && state.targetId!.isNotEmpty) {
                context.read<EventsBloc>().add(FetchEventForNavigation(state.targetId!));
              }
              context.read<NotificationBloc>().add(ClearNotificationIntent());
            }
          },
        ),
        BlocListener<DeepLinkBloc, DeepLinkState>(
          listener: (context, state) {
            if (state is DeepLinkPushEventDetail) {
              context.read<EventsBloc>().add(FetchEventForNavigation(state.eventId));
            }
          },
        ),
        BlocListener<EventsBloc, EventsState>(
          listenWhen: (previous, current) => previous.eventToNavigate != current.eventToNavigate,
          listener: (context, state) {
            if (state.eventToNavigate != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventDetailPage(event: state.eventToNavigate!)),
              );
              context.read<EventsBloc>().add(ResetEventNavigation());
            }
            if (state.status == EventsStatus.failure && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campo Base'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserSettings()),
              ),
            ),
          ],
        ),
        body: const EventsScreen(),
      ),
    );
  }
}
