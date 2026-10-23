import 'package:flutter/material.dart';

class TapScaleEffect extends StatefulWidget {
  /// Il widget figlio che riceverà l'animazione.
  final Widget child;

  /// La callback da eseguire al termine del "tap".
  final VoidCallback onTap;

  /// Il fattore di scala a cui rimpicciolirsi (es. 0.9 = 90% della dimensione originale).
  final double scaleFactor;

  /// La durata dell'animazione.
  final Duration duration;

  const TapScaleEffect({
    Key? key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.90, // Valore di default come nel tuo codice
    this.duration = const Duration(milliseconds: 100), // Durata di default
  }) : super(key: key);

  @override
  _TapScaleEffectState createState() => _TapScaleEffectState();
}

class _TapScaleEffectState extends State<TapScaleEffect>
    with SingleTickerProviderStateMixin { // Necessario per l'AnimationController
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor, // Usa il parametro del widget
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // Queste funzioni guidano l'animazione
  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    // Esegui l'azione e inverti l'animazione
    _scaleController.reverse();
    widget.onTap(); // Esegui la callback passata dall'esterno
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Rileva i gesti
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      // 2. Ricostruisci il widget quando l'animazione cambia
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          // 3. Applica la trasformazione di scala
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        // 4. Passa il widget.child all'AnimatedBuilder
        // Questo è il "child" che non viene ricostruito (più efficiente)
        child: widget.child,
      ),
    );
  }
}