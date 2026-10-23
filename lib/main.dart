import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/bloc/comments/comments_bloc.dart';
import 'package:campo_base/bloc/deep_link/deep_link_bloc.dart';
import 'package:campo_base/bloc/eventi/eventi_bloc.dart';
import 'package:campo_base/bloc/notification/notification_bloc.dart';
import 'package:campo_base/config.dart';
import 'package:campo_base/data/model/comment_enitity_type.dart';
import 'package:campo_base/data/repository/authRepository.dart';
import 'package:campo_base/data/repository/comments_repository.dart';
import 'package:campo_base/data/repository/eventiRepository.dart';
import 'package:campo_base/data/repository/token_repository.dart';
import 'package:campo_base/data/services/deep_link_service.dart';
import 'package:campo_base/data/services/notification_service.dart';
import 'package:campo_base/data/services/secure_storage_service.dart';
import 'package:campo_base/presentation/appView.dart';
import 'package:campo_base/temi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storageService = SecureStorageService();
  final pb = PocketBase(kApiBaseUrl);

  final authRepository = AuthRepository(pb: pb, persistenceService: storageService);
  final eventsRepository = EventiRepository(pb: pb, authRepository: authRepository);
  final commentsRepository = CommentsRepository(pb: pb, authRepository: authRepository);
  final userRepository = UserRepository(pb: pb);
  final notificationService = NotificationService();
  final deepLinkService = DeepLinkService();

  await authRepository.init();

  runApp(
    MyApp(
      authRepository: authRepository,
      eventsRepository: eventsRepository,
      commentsRepository: commentsRepository,
      userRepository: userRepository,
      notificationService: notificationService,
      deepLinkService: deepLinkService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final EventiRepository eventsRepository;
  final CommentsRepository commentsRepository;
  final UserRepository userRepository;
  final NotificationService notificationService;
  final DeepLinkService deepLinkService;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.eventsRepository,
    required this.commentsRepository,
    required this.userRepository,
    required this.notificationService,
    required this.deepLinkService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: eventsRepository),
        RepositoryProvider.value(value: commentsRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: notificationService),
        RepositoryProvider.value(value: deepLinkService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc(authRepository: authRepository)..add(CheckAuthStatus())),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationService: notificationService,
              userRepository: userRepository,
              authBloc: context.read<AuthBloc>(),
            )
              ..add(InitializeNotificationListeners())
              ..add(RequestNotificationPermissions()),
          ),
          BlocProvider<EventsBloc>(
            create: (context) => EventsBloc(
              eventsRepository: context.read<EventiRepository>(),
              authBloc: context.read<AuthBloc>(),
            )..add(LoadAllEvents()),
          ),
          BlocProvider<DeepLinkBloc>(
            create: (context) => DeepLinkBloc(deepLinkService: deepLinkService)..add(InitializeDeepLinkListener()),
          ),
          BlocProvider<CommentsBloc>(
            create: (context) => CommentsBloc(
              repository: commentsRepository,
              entityId: '',
              entityType: CommentEntityType.event,
              authRepository: authRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Campo Base',
          home: const AppView(),
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
