import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/deep_link_service.dart';

part 'deep_link_event.dart';
part 'deep_link_state.dart';

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  final DeepLinkService _deepLinkService;
  StreamSubscription? _linkSubscription;

  DeepLinkBloc({required DeepLinkService deepLinkService})
      : _deepLinkService = deepLinkService,
        super(DeepLinkInitial()) {
    on<InitializeDeepLinkListener>((event, emit) async {
      await _deepLinkService.init();

      // Ascolta lo stream dal service e trasforma in evento interno
      _linkSubscription = _deepLinkService.linkStream.listen((uri) {
        add(_DeepLinkReceived(uri));
      });
    });

    on<_DeepLinkReceived>((event, emit) {
      final uri = event.uri;
      final fullString = uri.toString();

      print("🔗 DEEPLINK: Analisi $fullString");

      // Se il link contiene 'eventi'
      if (fullString.contains('evento')) {
        // Logica per estrarre l'ID: prendiamo l'ultimo pezzo dell'URL
        // Es: campobase://evento/123 -> pathSegments: ['eventi', '123'] -> last: '123'
        if (uri.pathSegments.isNotEmpty) {
          final possibleId = uri.pathSegments.last;

          // Evitiamo che l'ID sia la parola 'eventi' stessa (nel caso il link sia solo /eventi)
          if (possibleId != 'evento') {
            print("✅ DEEPLINK: Trovato ID evento: $possibleId");
            emit(DeepLinkPushEventDetail(possibleId));
            return;
          }
        }
      }
    });

    on<ClearDeepLinkIntent>((event, emit) {
      emit(DeepLinkInitial());
    });
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    _deepLinkService.dispose();
    return super.close();
  }
}
