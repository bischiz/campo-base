part of 'deep_link_bloc.dart';

abstract class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();
  @override
  List<Object> get props => [];
}

class InitializeDeepLinkListener extends DeepLinkEvent {}

class _DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  const _DeepLinkReceived(this.uri);
  @override
  List<Object> get props => [uri];
}

class ClearDeepLinkIntent extends DeepLinkEvent {}
