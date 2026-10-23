# Campo Base

Il posto dove partono le tue avventure, e dove torni per condividerle e riviverle.

Piattaforma per creare e gestire eventi outdoor. Odyssey è uno degli organizzatori, non il gestore di tutto.

## Cosa c'è (importato da Odyssey, branch `VERSIONE3`, v4.0.0)

Lato partecipante:
- elenco eventi con tab Passati / Futuri e stato "Sei iscritto"
- dettaglio evento: descrizione, luogo, data, difficoltà, requisiti, organizzatore, partecipanti
- iscrizione e disiscrizione (iscrizioni aperte/chiuse), link al gruppo esterno, condivisione
- commenti sotto l'evento, con segnalazione ed eliminazione
- apertura evento da notifica push o da deep link

Comuni:
- login email/password e Google (PocketBase), registrazione con 18+ ed EULA, sessione salvata
- notifiche push (token FCM salvato sull'utente)
- impostazioni e logout

## Cosa manca (da costruire)

- Lato organizzatore: creazione/modifica evento, gestione iscritti e posti, comunicazioni ai partecipanti, pagina pubblica dell'organizzatore, più organizzatori
- Segnalazione e blocco utenti (nell'app Odyssey vivono nel profilo, qui non c'è ancora un profilo)
- Schermata profilo: oggi toccare un partecipante o l'autore di un commento non apre nulla
- Inbox notifiche in-app (quella di Odyssey è legata a like/commenti/tag delle avventure)
- Cartelle `android/`, `ios/`, `web/`: vanno generate (vedi sotto) con i nuovi identificativi
- Da decidere: stesso login di Odyssey oppure account separati

## Avvio

```
flutter create --org it.campobase --project-name campo_base .
flutterfire configure          # genera lib/firebase_options.dart per il progetto Firebase di Campo Base
flutter pub get
flutter run --dart-define=API_URL=https://<server-campo-base>
```

`API_URL` e `WEB_URL` (link condivisi) hanno come default `https://projectodyssey.it`, il PocketBase esistente con le collezioni `events` e `iscrizioni`, finché non c'è il server di Campo Base.

Per i deep link configura lo schema `campobase://` e gli URL `<WEB_URL>/evento/<id>` in Android e iOS.

Questo import non è stato compilato: nel container di lavoro non c'era Flutter. Alla prima `flutter analyze` aspettati qualche correzione.

## Sicurezza

Non sono stati copiati `ambiente.env`, `google-services.json`, `GoogleService-Info.plist` e `firebase_options.dart` di Odyssey.
