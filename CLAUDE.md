# CLAUDE.md
# Diese Datei liegt im Root deines Projekts.
# Claude liest sie bei jedem Start automatisch.
# Halte sie aktuell — sie erspart dir hunderte Erklärungen.

---

## Projekt-Übersicht

**Name:** Tempo — Metronome for Musicians
**Beschreibung:** Minimales, präzises Metronom für iPhone und Apple Watch. Gebaut mit SwiftUI und AVAudioEngine. Keine externen Dependencies — ausschliesslich Apple-Frameworks.
**Status:** Frühe Entwicklung (leere App-Struktur, Features noch nicht implementiert)
**Ziel:**  — beides
**GitHub Repo:** https://github.com/david-engel-05/tempo-metronome

---

## Tech-Stack

**Plattform:** iOS 17+ / watchOS 10+
**Sprache:** Swift 5.9
**Framework:** SwiftUI, `@Observable` (Swift 5.9+)
**Datenbank / Backend:** keine
**Wichtige Frameworks (Apple only):**
- `AVAudioEngine` — Metronom-Audio-Engine
- `CoreHaptics` — haptisches Feedback (stärkerer Akzent auf Beat 1)
- `WatchConnectivity` — [?] Kommunikation zwischen iPhone und Watch

---

## Projektstruktur

Geplante Zielstruktur (aus README — noch nicht vollständig umgesetzt):

```
Tempo/
├── App/
│   └── TempoApp.swift          # App entry point
├── Views/
│   ├── MainView.swift          # Haupt-Metronom-Screen
│   ├── BPMControlView.swift    # BPM Slider + Tap Tempo
│   └── TimeSigView.swift       # Taktart-Auswahl
├── Engine/
│   ├── MetronomeEngine.swift   # AVAudioEngine-Logik
│   └── HapticEngine.swift      # CoreHaptics-Manager
└── Models/
    └── MetronomeState.swift    # App-State (@Observable)

TempoWatch/
├── WatchApp.swift
└── WatchMainView.swift
```

Aktueller Stand im Repo:
```
tempo-metronome/
├── tempo_metronomeApp.swift    # Entry Point (generiert)
└── ContentView.swift           # Noch leer / Platzhalter
```

**Was wo liegt:**
- `Views/` → Alle Screens und UI-Komponenten (max. ~100 Zeilen pro View)
- `Engine/` → Audio- und Haptics-Logik (kein UI-Code hier)
- `Models/` → Datenstrukturen und App-State

---

## Geplante Features

- BPM-Kontrolle: Slider, Tap Tempo, manuelle Eingabe (20–300 BPM)
- Taktarten: 4/4, 3/4, 6/8, 5/4, 7/8 — erster Beat akzentuiert
- Sound-Auswahl: Click, Wood, Beep, Hi-Hat + Lautstärkeregler
- Haptik: CoreHaptics, stärkere Vibration auf Beat 1
- Apple Watch: Tap Tempo am Handgelenk, Haptic-Only-Modus

---

## Code-Konventionen

### Allgemein
- Sprache im Code: **Englisch** (Variablen, Funktionen, Kommentare)
- Keine externen Dependencies — ausschliesslich Apple-Frameworks
- Kommentare nur wo nötig — guter Code erklärt sich selbst

### SwiftUI
- Views klein halten: max. ~100 Zeilen pro View
- Business-Logik gehört in `Engine/`, nicht in Views
- `@Observable` für State-Management (kein `ObservableObject`)
- `@State` nur für lokalen UI-State
- Farben und Text über `Assets.xcassets` / eigene Constants

### Naming
- Views: `MainView`, `BPMControlView` (PascalCase + "View")
- Engine-Klassen: `MetronomeEngine`, `HapticEngine` (PascalCase)
- Functions: `startPlayback()`, `updateBPM()` (camelCase, Verb zuerst)
- Konstanten: — eigene `Constants.swift` Datei geplant? : ja

---

## Git-Workflow

### Branches
- `main` → stabiler, funktionierender Code — nie direkt committen
- Feature-Branches: `feature/12-streak-counter` (Issue-Nummer + kurze Beschreibung)
- Bugfix-Branches: `fix/17-crash-on-launch`

### Commits
- Auf Englisch, klein und fokussiert (eine Sache pro Commit)
- Format: `typ: kurze Beschreibung`
- Typen: `feat` / `fix` / `refactor` / `docs` / `style`
- Beispiele:
  - `feat: add tap tempo to BPMControlView`
  - `fix: correct accent timing on beat one`

### Pull Requests
- Jeder PR löst genau ein Issue
- Titel = Issue-Titel
- Beschreibung: Was wurde geändert? Warum? Wie testen?
- PR wird erst gemergt nachdem ich (Yanis) den Diff gelesen habe
- Auf iPhone-Simulator **und** Apple Watch Simulator testen wenn relevant

---

## GitHub Issues Workflow

### Issue-Labels
- `feature` → neue Funktionalität
- `bug` → etwas funktioniert nicht
- `learning` → ich will das zuerst verstehen bevor Claude es baut
- `claude` → Claude übernimmt selbstständig
- `blocked` → wartet auf etwas anderes

### Wenn Claude ein Issue erstellt
Claude soll Issues mit `gh issue create` erstellen mit:
- Klarem Titel
- Kurzer Beschreibung was zu tun ist
- Passendem Label
- Wenn nötig: Hinweis auf abhängige Issues

### Wenn ich sage "arbeite an Issue #X"
1. Issue lesen und kurz zusammenfassen was zu tun ist
2. Plan zeigen — noch kein Code
3. Auf meine Bestätigung warten
4. Branch erstellen: `git checkout -b feature/X-beschreibung`
5. In kleinen Commits arbeiten
6. PR erstellen mit `gh pr create`
7. Erklären was geändert wurde und was ich daraus lernen kann

---

## Was Claude NICHT anfassen soll

- `tempo-metronome.xcodeproj/` → Xcode-Projektdatei, nur Xcode bearbeitet diese
- Keine externen Dependencies (SPM-Pakete) ohne explizite Absprache hinzufügen
- Keine bestehenden Funktionen umbenennen ohne Hinweis
- Nie direkt in `main` committen
- Keine Issues schliessen — das mache ich nach dem Review selbst


---

## Bekannte Eigenheiten / Stolpersteine

- Die App-Struktur im README entspricht **nicht** dem aktuellen Stand im Repo — der Code ist noch leer/generiert
- `@Observable` (Swift 5.9) ist neu und anders als `@ObservableObject` — nicht verwechseln
- Audio auf dem Simulator klingt anders als auf echtem Gerät — bei Soundänderungen auf Device testen
- Apple Watch Simulator hat keine echten Haptik-Ausgaben
- [?] — Weitere bekannte Probleme?

---

## Lern-Modus

Ich will verstehen was ich baue. Bitte:
- Erkläre neue Konzepte kurz bevor du sie implementierst
- Wenn du eine Entscheidung triffst, sag warum
- Bei grösseren Änderungen: erst Plan zeigen, dann auf Bestätigung warten
- Fachbegriffe beim ersten Mal kurz erklären
- Nach einem PR kurz zusammenfassen was ich daraus gelernt haben sollte

---

## Aktueller Fokus

App-Grundstruktur aufbauen — die Ordnerstruktur aus der README (`App/`, `Views/`, `Engine/`, `Models/`) im Xcode-Projekt anlegen und mit erstem Inhalt füllen.

---

## Offene Notizen

<!-- Werden als GitHub Issues getrackt — hier nur kurzfristige Notizen -->
- [ ] GitHub Repo URL eintragen
- [ ] Projektziel definieren (App Store / Lernprojekt)
- [ ] Ordnerstruktur in Xcode anlegen (entspricht noch nicht der README)
- [ ] [?] Weitere offene Punkte?
