import 'package:campo_base/config.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:campo_base/bloc/comments/comments_bloc.dart';
import 'package:campo_base/bloc/comments/comments_event.dart';
import 'package:campo_base/bloc/event_detail/event_detail_bloc.dart';
import 'package:campo_base/bloc/eventi/eventi_bloc.dart';
import 'package:campo_base/data/model/comment_enitity_type.dart';
import 'package:campo_base/data/repository/comments_repository.dart';
import 'package:campo_base/data/model/eventModel.dart';
import 'package:campo_base/data/repository/authRepository.dart';
import 'package:campo_base/data/repository/eventiRepository.dart';
import 'package:campo_base/presentation/comment_section_ui.dart';
import 'package:campo_base/presentation/profile_card.dart';
import 'package:campo_base/presentation/widgets/glass_button.dart';
import 'package:campo_base/temi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;
  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventDetailBloc(
        eventsRepository: RepositoryProvider.of<EventiRepository>(context),
      )..add(LoadEventDetails(event.id)),
      child: _EventDetailView(event: event),
    );
  }
}

class _EventDetailView extends StatefulWidget {
  final EventModel event;
  const _EventDetailView({Key? key, required this.event}) : super(key: key);

  @override
  State<_EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<_EventDetailView> {
  //BannerAd? _bannerAd;
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  /*  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  } */

  void _loadAd() {
    // Logica banner
  }

  void _displayDialog(BuildContext context, String title, {String? content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(220, 194, 194, 194),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
        content: content != null ? Text(content, textAlign: TextAlign.center) : null,
        actionsAlignment: MainAxisAlignment.center,
        actions: content == null
            ? null
            : [
                ElevatedButton(
                  onPressed: () => _launchURL(widget.event.linkgruppo),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                    const ui.Color.fromARGB(120, 7, 86, 223),
                  )),
                  child: const Text(
                    'Unisciti',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    }
  }

  void _handleSubscription(BuildContext context, EventModel currentEvent) {
    if (!currentEvent.date.isBefore(DateTime.now())) {
      if (currentEvent.iscrizioniAperte) {
        if (!currentEvent.iscritto) {
          context.read<EventsBloc>().add(SubscribeToEvent(currentEvent.id));
        } else {
          context.read<EventsBloc>().add(UnsubscribeFromEvent(currentEvent.id));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<EventsBloc, EventsState>(
        listener: (context, state) {
          final updatedEvent =
              state.officialEvents.firstWhere((e) => e.id == widget.event.id, orElse: () => widget.event);
          final originalEvent = widget.event;

          if (updatedEvent.iscritto == true && originalEvent.iscritto == false) {
            _displayDialog(
              context,
              "Sei stato iscritto correttamente",
              content:
                  "Ti verrà inviata una mail con informazioni più dettagliate.\nNel frattempo unisciti al gruppo Whatsapp per restare aggiornato sugli sviluppi dell'evento!",
            );
          } else if (updatedEvent.iscritto == false && originalEvent.iscritto == true) {
            _displayDialog(context, "Disiscrizione riuscita!");
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.0,
              pinned: true,
              backgroundColor: Colors.black26,
              leadingWidth: 80,
              leading: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GlassButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GlassButton(
                      icon: Icons.share,
                      onTap: () {
                        Share.share(
                            "Scopri questo evento su Campo Base! \n $kWebBaseUrl/evento/${widget.event.id}");
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                title: BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    final currentEvent = state.officialEvents.firstWhere(
                      (e) => e.id == widget.event.id,
                      orElse: () => widget.event,
                    );

                    String buttonText;
                    bool isPassed = currentEvent.date.isBefore(DateTime.now());
                    bool isAvailable = !isPassed && currentEvent.iscrizioniAperte;

                    Gradient buttonGradient;
                    List<BoxShadow>? shadows;

                    if (!isAvailable) {
                      buttonText = 'NON DISPONIBILE';
                      buttonGradient = LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.3),
                        ],
                      );
                      shadows = null; // Nessuna ombra per il bottone inattivo
                    } else if (currentEvent.iscritto) {
                      buttonText = 'DISISCRIVITI';
                      buttonGradient = const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          ui.Color.fromARGB(101, 0, 131, 129), // Meno saturo
                          ui.Color.fromARGB(101, 0, 42, 114) // Meno saturo
                        ],
                      );
                      shadows = [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ];
                    } else {
                      buttonText = 'ISCRIVITI';
                      buttonGradient = LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          gradientComplementary.withOpacity(0.4),
                          const ui.Color.fromARGB(120, 7, 86, 223),
                        ],
                      );
                      shadows = [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ];
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.event.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTapDown: isAvailable ? (_) => setState(() => _buttonScale = 0.92) : null,
                          onTapUp: isAvailable ? (_) => setState(() => _buttonScale = 1.0) : null,
                          onTapCancel: isAvailable ? () => setState(() => _buttonScale = 1.0) : null,
                          onTap: isAvailable ? () => _handleSubscription(context, currentEvent) : null,
                          child: AnimatedScale(
                            scale: _buttonScale,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: shadows,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: buttonGradient,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(isAvailable ? 0.4 : 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      buttonText,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(isAvailable ? 1.0 : 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'event_header_${widget.event.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.event.image,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: Colors.grey),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: odysseyBlue.withOpacity(0.1),
                              child: const Icon(Icons.emoji_flags, color: odysseyBlue),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Organizzato da", style: TextStyle(fontSize: 10, color: odysseyGrey)),
                                Text(
                                  widget.event.organizzatore,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailStat("Località", widget.event.place, Icons.place, isHighlight: true),
                          _buildDetailStat("Difficoltà", widget.event.difficulty, Icons.bar_chart, isHighlight: true),
                          _buildDetailStat(
                              "Data",
                              "${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}",
                              Icons.calendar_today,
                              isHighlight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Descrizione Evento",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: odysseyBlue)),
                    const SizedBox(height: 5),
                    Text(
                      widget.event.description,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    if (widget.event.requirements.isNotEmpty) ...[
                      const Text("Requisiti",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: odysseyBlue)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.event.requirements.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: odysseyBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 16, color: odysseyBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.event.requirements[index].toString(),
                                    style: const TextStyle(color: odysseyBlue, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    const Text("Partecipanti",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: odysseyBlue)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: BlocBuilder<EventDetailBloc, EventDetailState>(
                        builder: (context, state) {
                          if (state.status == EventDetailStatus.loading) {
                            return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: odysseyBlue,
                                size: 30,
                              ),
                            );
                          }
                          if (state.participants.isEmpty) {
                            return const Center(
                                child: Text("Sii il primo a partecipare!", style: TextStyle(color: odysseyGrey)));
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.participants.length,
                            itemBuilder: (context, index) {
                              final participant = state.participants[index];
                              return ProfileCard(
                                layout: ProfileCardLayout.vertical,
                                title: participant.nomeUtente,
                                imageUrl: participant.imageUrl,
                                // TODO: aprire il profilo del partecipante quando esisterà la schermata profilo di Campo Base
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Commenti",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: odysseyBlue)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 400,
                      child: BlocProvider(
                        create: (context) => CommentsBloc(
                          repository: context.read<CommentsRepository>(),
                          authRepository: context.read<AuthRepository>(),
                          entityId: widget.event.id,
                          entityType: CommentEntityType.event,
                        )..add(LoadComments()),
                        child: CommentsSectionUI(),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Column(
      children: [
        Icon(icon, color: isHighlight ? odysseyBlue : odysseyLightBlue, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isHighlight ? odysseyBlue : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        Text(label, style: const TextStyle(color: odysseyGrey, fontSize: 11)),
      ],
    );
  }
}
