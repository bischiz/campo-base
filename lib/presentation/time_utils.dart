class TimeUtils {
  /// Converte input vari (4.30, 4:30, 4 30, 4,5) in formato decimale standard (4.5)
  /// Esempio: "4.30" diventa 4.5 (4 ore e mezza), NON 4.3.
  static double? parseFlexibleTime(String input) {
    if (input.isEmpty) return null;

    // 1. Pulizia: rimuovi spazi extra e normalizza i separatori
    String clean = input.trim().replaceAll(RegExp(r'\s+'), '.').replaceAll(',', '.').replaceAll(':', '.');
    
    // Gestione caso "4h30"
    clean = clean.replaceAll(RegExp(r'[a-zA-Z]'), '.');

    try {
      // Se c'è un separatore, analizziamo ore e minuti
      if (clean.contains('.')) {
        final parts = clean.split('.');
        
        // Caso "4." -> 4.0
        if (parts[1].isEmpty) return double.tryParse(parts[0]);
        
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        
        // Validazione base minuti
        if (minutes >= 60) return null; // "4.90" non esiste come orario
        
        // Conversione minuti in ore decimali
        // Es: 30 minuti / 60 = 0.5 ore. 
        // Risultato finale: 4 + 0.5 = 4.5
        return hours + (minutes / 60.0);
      } else {
        // Solo numero intero (es. "4")
        return double.tryParse(clean);
      }
    } catch (e) {
      return null;
    }
  }

  /// Verifica solo se è valido senza restituire il valore
  static bool isValidTime(String input) {
    return parseFlexibleTime(input) != null;
  }
}