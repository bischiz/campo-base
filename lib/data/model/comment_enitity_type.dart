enum CommentEntityType { event, adventure, place }

extension CommentTypeExtension on CommentEntityType {
  /// Il nome della collection su PocketBase
  String get collectionName {
    switch (this) {
      case CommentEntityType.event:
        return 'commenti_eventi';
      case CommentEntityType.adventure:
        return 'commenti_avventure';
      case CommentEntityType.place:
        return 'commenti'; // Hai detto che per i posti si chiama "commenti"
    }
  }

  /// Il nome del campo relazione dentro la collection che punta all'entità padre.
  /// Esempio: in 'commenti_eventi' c'è un campo 'evento' che punta all'ID dell'evento.
  String get relationField {
    switch (this) {
      case CommentEntityType.event:
        return 'posto'; // Assumo il campo si chiami così
      case CommentEntityType.adventure:
        return 'avventura'; // Assumo il campo si chiami così
      case CommentEntityType.place:
        return 'posto'; // Assumo il campo si chiami così
    }
  }
}
