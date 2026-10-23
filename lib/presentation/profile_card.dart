import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campo_base/temi.dart';

/// Definisce i vari stili visivi che la card può assumere
enum ProfileCardLayout {
  /// Stile scheda con sfondo, ombra e bordi arrotondati (es. Classifiche)
  card,
  
  /// Stile piatto senza sfondo, ideale per liste lunghe o commenti (es. Feed, Commenti)
  flat,
  
  /// Stile minimale per intestazioni (es. "Creato da" nelle pagine dettaglio)
  header,
  
  /// Stile verticale con avatar sopra e nome sotto (es. Liste partecipanti orizzontali)
  vertical,
}

class ProfileCard extends StatelessWidget {
  /// Titolo principale (es. Nome Utente)
  final String title;
  
  /// Sottotitolo opzionale (es. "Livello 5", "Creato da")
  final String? subtitle;
  
  /// URL dell'immagine profilo
  final String? imageUrl;
  
  /// Widget da mostrare alla fine della riga del titolo (es. Punteggio, Data, Menu)
  final Widget? trailing;
  
  /// Contenuto principale del corpo (es. Il testo del commento).
  /// Viene mostrato sotto il titolo/sottotitolo.
  final Widget? content;
  
  /// Azione al tocco
  final VoidCallback? onTap;
  
  /// Se true, applica un colore di sfondo speciale (es. Utente corrente in classifica)
  final bool isHighlighted;
  
  /// Il layout da utilizzare
  final ProfileCardLayout layout;
  
  /// Sovrascrittura opzionale della dimensione dell'avatar
  final double? avatarRadius;

  const ProfileCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.trailing,
    this.content,
    this.onTap,
    this.isHighlighted = false,
    this.layout = ProfileCardLayout.card,
    this.avatarRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case ProfileCardLayout.vertical:
        return _buildVerticalLayout(context);
      case ProfileCardLayout.header:
        return _buildHeaderLayout(context);
      case ProfileCardLayout.flat:
        return _buildFlatLayout(context);
      case ProfileCardLayout.card:
      default:
        return _buildCardLayout(context);
    }
  }

  // --- 1. LAYOUT VERTICALE (Per liste orizzontali di partecipanti) ---
  Widget _buildVerticalLayout(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(avatarRadius ?? 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. LAYOUT HEADER (Per intestazioni "Creato da") ---
  Widget _buildHeaderLayout(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(avatarRadius ?? 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 10, color: odysseyGrey)),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. LAYOUT FLAT (Per Commenti e Feed) ---
  // Questo layout supporta il parametro 'content' indentato correttamente
  Widget _buildFlatLayout(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: isHighlighted 
                ? const Color.fromARGB(255, 123, 189, 255).withOpacity(0.8) 
                : const Color.fromARGB(255, 232, 232, 232).withOpacity(0.8), // Aggiunto opacity per effetto vetro
          ),
          // È necessario un Material trasparente per far funzionare l'InkWell sopra una decorazione
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap, // <--- Qui viene ripristinato il click
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12), // Padding leggermente aumentato per touch target migliore
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Colonna Sinistra: Avatar
                    _buildAvatar(avatarRadius ?? 20),
                    
                    const SizedBox(width: 12),
                    
                    // Colonna Destra: Tutto il testo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Riga Superiore: Nome + (Date/Trailing)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 14, 
                                    color: isHighlighted ? odysseyBlue : Colors.black87
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (trailing != null) 
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: trailing!,
                                ),
                            ],
                          ),
                          
                          // Sottotitolo (es. Livello utente nei commenti, opzionale)
                          if (subtitle != null) ...[
                            Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],

                          // IL CONTENUTO (Il testo del commento)
                          if (content != null) ...[
                            const SizedBox(height: 4),
                            content!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. LAYOUT CARD (Per Classifiche) ---
  Widget _buildCardLayout(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isHighlighted 
          ? const Color.fromARGB(170, 189, 255, 254) 
          : Theme.of(context).cardColor,
      elevation: isHighlighted ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding interno custom
          child: Row(
            children: [
              _buildAvatar(avatarRadius ?? 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: isHighlighted ? Colors.black87 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 13
                        ),
                      ),
                    // Se volessimo mettere contenuto anche nella card, lo aggiungiamo qui
                    if (content != null) ...[
                      const SizedBox(height: 8),
                      content!,
                    ]
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: COSTRUZIONE AVATAR ---
  Widget _buildAvatar(double radius) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
        onBackgroundImageError: (_, __) => const Icon(Icons.person, color: Colors.grey),
      );
    } else {
      // Fallback se manca l'immagine: Iniziale del nome
      return CircleAvatar(
        radius: radius,
        backgroundColor: odysseyBlue.withOpacity(0.1),
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : "?",
          style: const TextStyle(color: odysseyBlue, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}