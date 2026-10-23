import 'package:campo_base/presentation/schedaeventi.dart';
import 'package:campo_base/temi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campo_base/bloc/eventi/eventi_bloc.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Non serve un BlocProvider qui, è già in main.dart
    return const _EventsView();
  }
}

class _EventsView extends StatefulWidget {
  const _EventsView({Key? key}) : super(key: key);

  @override
  _EventsViewState createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: context.read<EventsBloc>().state.selectedPageIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsBloc, EventsState>(
      listener: (context, state) {
        if (_pageController.hasClients && state.selectedPageIndex != _pageController.page?.round()) {
          _pageController.animateToPage(
            state.selectedPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      builder: (context, state) {
        // Stato di caricamento
        if (state.status == EventsStatus.loading || state.status == EventsStatus.initial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Stato di errore
        if (state.status == EventsStatus.failure) {
          return Scaffold(body: Center(child: Text('Errore: ${state.error}')));
        }

        // Stato di successo
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomTabBar(context, state.selectedPageIndex), // La tua TabBar
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      context.read<EventsBloc>().add(ChangeEventsPage(page));
                    },
                    children: [
                      // Pagina 0: Passati
                      EventsPage(state.pastEvents), // <-- USA LA TUA UI!

                      // Pagina 1: Ufficiali
                      EventsPage(state.officialEvents), // <-- USA LA TUA UI!
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ricostruisco i tuoi metodi helper
  Widget _buildCalendarButton(BuildContext context, EventsState state) {
    return GestureDetector(
      onTap: () {
        // ... (tutta la tua logica showModalBottomSheet) ...
      },
      child: const Row(
        children: [
          Icon(Icons.calendar_today, size: 24.0, color: Colors.blue),
          SizedBox(width: 20.0),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context, int currentPage) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // ... (tutta la tua grafica per la TabBar) ...
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabItem(context, "Passati", 0, currentPage),
            const SizedBox(width: 10),
            _buildTabItem(context, "Futuri", 1, currentPage),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String text, int pageIndex, int currentPage) {
    final bool isSelected = (pageIndex == currentPage);
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        //margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          shape: BoxShape.rectangle,
          color: Color.fromARGB(210, 3, 81, 217), // Change color based on active page
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }
    return GestureDetector(
      onTap: () {
        context.read<EventsBloc>().add(ChangeEventsPage(pageIndex));
      },
      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
    );
  }
}
