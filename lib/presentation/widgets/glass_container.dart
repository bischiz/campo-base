import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    // Colore di default più leggero per evitare scurimenti eccessivi sovrapposti
    this.backgroundColor = Colors.white54, 
    this.borderColor = const Color.fromARGB(178, 255, 255, 255),
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // NOTA: Abbiamo rimosso il BackdropFilter da qui per le performance.
    // La sfocatura deve essere gestita dallo sfondo della schermata padre.
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        //border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}