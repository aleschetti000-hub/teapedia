# Teapedia

Enciclopedia tascabile dei tè e infusi, con diario personale di degustazione. Prima versione solo in italiano, target utenti italiani appassionati di tè.

## Tech stack

- Flutter 3.41.7 / Dart 3.11.5
- Nessun state management ancora (si valuterà quando la complessità lo richiede)
- Nessun database ancora (si valuterà quando serve il diario di degustazione)
- Dati locali via `assets/data/teas.json`

## Struttura cartelle

```
lib/
  models/     # Classi dati pure (Tea, ecc.) con fromJson
  data/       # Repository per caricare e filtrare i dati dal JSON
  screens/    # Una schermata per file (HomeScreen, CategoryListScreen, ecc.)
  widgets/    # Componenti riutilizzabili tra più schermate
  theme/      # AppTheme con tutti i colori e il ThemeData
assets/
  data/       # File JSON con i dati dei tè
```

## Convenzioni UI

- Material 3 sempre (`useMaterial3: true`)
- Font di sistema di default (niente Google Fonts per ora)
- Colori sempre da `AppTheme` — niente valori hex inline tranne in AppTheme stesso
- Niente gradienti
- Corner radius: 10px per container/input, 12px per card
- Sfondo scaffold: bianco (`Colors.white`)

## Come lavorare con Alessandro (Ale)

- È programmatore Python, non ancora esperto Flutter: quando usi pattern specifici Flutter/Dart spiega brevemente il perché (es. perché `const`, perché `StatelessWidget` vs `StatefulWidget`)
- Preferisce risposte concise, non muri di testo
- Lingua: italiano

## Regole operative

- Fai un commit Git dopo ogni feature funzionante completata (non durante i lavori in corso)
- Non aggiungere dipendenze al `pubspec.yaml` senza prima discuterne
- Non introdurre state management o database prima che la UI base sia completata
