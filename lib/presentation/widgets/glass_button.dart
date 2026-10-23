import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlassButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassButton({super.key, required this.icon, required this.onTap});

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80), 
    );
    
    _tiltAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Il Guerriero non agisce d'impulso, ma con intenzione completa.
  Future<void> _handleTap() async {
    // 1. Assicuriamoci che l'inclinazione arrivi al massimo (anche se il tocco è rapido)
    await _controller.forward();
    
    // 2. Assicuriamoci che torni alla posizione di riposo
    await _controller.reverse();
    // 4. Ora, e solo ora, eseguiamo il comando
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Usiamo solo onTap per gestire la sequenza completa in modo atomico
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _tiltAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Prospettiva
              ..rotateX(_tiltAnimation.value) // Inclinazione verticale
              ..rotateY(_tiltAnimation.value * 0.5), // Leggera rotazione laterale
            alignment: Alignment.center,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}