import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:campo_base/temi.dart'; // Per odysseyBlue, etc.

class GlassActionMenu extends StatefulWidget {
  final bool isOwner;
  final bool hasActivity;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback? onReport; // Nuovo callback opzionale

  const GlassActionMenu({
    super.key,
    required this.isOwner,
    required this.hasActivity,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
    this.onReport, // Passalo se necessario
  });

  @override
  State<GlassActionMenu> createState() => _GlassActionMenuState();
}

class _GlassActionMenuState extends State<GlassActionMenu> {
  bool _isExpanded = false;

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcoliamo la larghezza dinamica in base alle opzioni disponibili
    double expandedWidth = 60.0; // Bottone chiudi (base)
    
    if (widget.isOwner) {
      expandedWidth += 100.0; // Modifica (50) + Elimina (50)
    } else {
      // Se non è owner, c'è il tasto report (se passato)
      if (widget.onReport != null) expandedWidth += 50.0;
    }

    if (widget.hasActivity) expandedWidth += 50.0; // Condividi

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutQuart,
      width: _isExpanded ? expandedWidth : 50,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
            ),
            child: _isExpanded ? _buildExpandedRow() : _buildCollapsedIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedIcon() {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onPressed: _toggleMenu,
    );
  }

  Widget _buildExpandedRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // --- AZIONI PROPRIETARIO ---
        if (widget.isOwner) ...[
          _ActionIcon(icon: Icons.delete, color: Colors.redAccent, onTap: widget.onDelete),
          _ActionIcon(icon: Icons.edit, color: Colors.white, onTap: widget.onEdit),
        ],

        if (!widget.isOwner && widget.onReport != null)
          _ActionIcon(icon: Icons.flag, color: Colors.redAccent, onTap: widget.onReport!),
        // --- AZIONI PUBBLICHE ---
        if (widget.hasActivity)
          _ActionIcon(icon: Icons.share, color: Colors.white, onTap: widget.onShare),

        // --- AZIONI NON PROPRIETARIO (REPORT) ---
        

        // --- CHIUDI ---
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: _toggleMenu,
        ),
      ],
    );
  }
}

// Piccolo helper per le icone delle azioni
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}