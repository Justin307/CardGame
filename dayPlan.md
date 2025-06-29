# Projekt: Strategická hra s karetním soubojem (Dice Wars styl)

## Plán práce (11 dní / 38 hodin) - ChatGPT

---

## 🗓️ DEN 1 (4h): Nastavení projektu + mapa + území

### ✅ Úlohy:

* Vytvořit Godot 4 projekt
* Hlavní scéna `Main.tscn` (Node2D)
* Uzel `Map` (Node2D)
* Vytvořit 4–6 území jako `Area2D + Polygon2D + CollisionPolygon2D`
* Každému území nastavit ID a vlastníka

## 🗓️ DEN 2 (2h): Výběr území a cíl útoku

### ✅ Úlohy:

* Umožnit kliknutí na vlastní území (výběr zdroje)
* Kliknutí na sousední nepřátelské území (výběr cíle)
* Uložit výběr do proměnných a zvýraznit obě políčka

## 🗓️ DEN 3 (2h): Vizualizace karet

### ✅ Úlohy:

* Každé území má počet karet (1–6)
* Karty reprezentují čísla (2–14)
* Na mapě zobrazit počet karet jako text

## 🗓️ DEN 4 (2h): Mechanika boje

### ✅ Úlohy:

* Vygenerovat náhodné hodnoty karet pro obě strany
* Sečíst hodnoty a porovnat
* Vítěz převezme kontrolu nad cílovým územím

## 🗓️ DEN 5 (2h): Bonus za barvu karet

### ✅ Úlohy:

* Zavést barvy karet (♥ ♦ ♣ ♠)
* V remíze vyhrává obránce
* Útočník vyhrává, pokud má všechny karty stejné barvy

## 🗓️ DEN 6 (6h): Tahy hráčů a posily

### ✅ Úlohy:

* Přepínání hráče (`current_player`)
* Tlačítko „Konec tahu“
* Na konci tahu každé území získá novou kartu
* Reset výběru po tahu

## 🗓️ DEN 7 (6h): Dokončení hry + UI

### ✅ Úlohy:

* Kontrola vítězství (jeden hráč ovládá všechna území)
* Restartování hry
* UI panel: aktivní hráč, počet území, stav výběru
* Dialogové okno s informací o vítězství

## 🗓️ DEN 8 (6h): Vylepšení vzhledu + refaktoring

### ✅ Úlohy:

* Barvy území podle hráče
* Ikony nebo fonty pro karty
* Přesunout skripty do složek `Scripts`, scény do `Scenes`, atd.
* Vyčistit a komentovat kód

## 🗓️ DEN 9 (2h): Testování a ladění

### ✅ Úlohy:

* Testovat hraniční situace (1 území, remízy, žádný cíl)
* Opravit chyby nalezené během testování

## 🗓️ DEN 10 (2h): GitHub + dokumentace

### ✅ Úlohy:

* Vytvořit repozitář a commitnout projekt
* Přidat `.gitignore`, `README.md` a `idea.md`
* Přidat screenshoty a návod ke spuštění

## 🗓️ DEN 11 (2h): Finalizace + prezentace

### ✅ Úlohy:

* Doladit zvuky nebo animace (volitelné)
* Otestovat hru ve dvou hráčích
* Prezentovat, případně vytvořit krátké video

---

Celkově 38 hodin, rozvržených do 11 dnů.
