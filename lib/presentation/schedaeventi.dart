import 'package:campo_base/data/model/eventModel.dart';
import 'package:campo_base/presentation/evento_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

String shortenDescription(String description) {
  const maxLength = 100; // Define the maximum length for description

  if (description.length <= maxLength) {
    return description;
  } else {
    return '${description.substring(0, maxLength)}...';
  }
}

/// A stateful widget that displays a list of events in a scrollable ListView.
class EventsPage extends StatefulWidget {
  final List<EventModel> eventData;

  const EventsPage(this.eventData, {super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.eventData.length,
      itemBuilder: (context, index) {
        if (widget.eventData[index].id == "machupichu") {
          return Container(
            height: 300,
          );
        }
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(event: widget.eventData[index]),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      widget.eventData[index].iscritto
                          ? const Color.fromARGB(164, 21, 212, 37)
                          // : const Color.fromARGB(255, 51, 121, 226),
                          : const Color.fromARGB(221, 181, 220, 255),
                      widget.eventData[index].iscritto
                          ? const Color.fromARGB(183, 188, 241, 167)
                          // : const Color.fromARGB(255, 129, 216, 209),
                          : const Color.fromARGB(144, 218, 237, 255),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 20, 37).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow position, adjust as needed
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height / 3,
                child: Row(
                  children: [
                    // Left side image CON HERO ANIMATION
                    Hero(
                      tag: 'event_header_${widget.eventData[index].id}',
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        height: double.infinity, // Assicura che riempia l'altezza disponibile
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.eventData[index].image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    // Right side content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date at top right
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                widget.eventData[index].getNaturalDate(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // Title

                            Text(
                              widget.eventData[index].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.eventData[index].iscritto
                                    ? const Color.fromARGB(255, 0, 124, 10)
                                    : Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Description
                            Text(
                              widget.eventData[index].description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.eventData[index].iscritto
                                          ? const Color.fromARGB(255, 86, 189, 46)
                                          : const Color.fromARGB(225, 2, 85, 233),
                                      widget.eventData[index].iscritto
                                          ? const Color.fromARGB(255, 0, 124, 10)
                                          : const Color.fromARGB(170, 10, 151, 202),
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailPage(event: widget.eventData[index]),
                                      ),
                                    );
                                  },
                                  child: Ink(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.eventData[index].iscritto ? "Sei Iscritto" : "Scopri di più",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Organizzato da ${widget.eventData[index].organizzatore}', // Replace with your text
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
