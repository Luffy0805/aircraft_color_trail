# Minetest Mod : Aircraft Color Trail

Par Luffy0805
Version : 1.0.0
Licence : MIT

---

## Description

Ce mod ajoute des traînées de fumée colorées personnalisables pour les avions d'APercy.

Les joueurs peuvent activer ou désactiver la fumée colorée pendant le vol grâce à une télécommande spéciale, avec plusieurs modes d'affichage :

* Mode 1 : Jet arrière central
* Mode 2 : Jets latéraux symétriques
* Mode 3 : Jets latéraux à double teinte (utilise deux teintures)

Le mod prend en charge la consommation de teinture, les particules de fumée animées, et est personnalisable par avion.

---

## Compatibilité

Ce mod est compatible avec la plupart des avions d'APercy, comme :

* PA-28
* Supercub, Superduck Hydroplane
* JU 52 3M, JU 52 3M Hydroplane
* F1 Camel et Albatros du mod WW1
* Savoia S21

Il **ne modifie pas** ces mods d'avion. Toutes les interactions sont gérées de manière externe, ce qui rend l'installation et les mises à jour transparentes.

---

## Installation

1. Copier le dossier du mod dans `mods/` de votre installation Minetest.
2. Activer le mod pour votre monde.
3. Assurez-vous que les mods d'avions souhaités sont installés et actifs.

---

## Utilisation

* Fabriquez ou obtenez la `Télécommande de Fumée Colorée` (`pa28_color_trail:remote`).
* Équipez-la dans votre main.
* Cliquez gauche pour activer/désactiver la fumée.
* Utilisez `AUX1` ou `SNEAK` + clic gauche pour changer de mode.
* Placez des teintures dans l'inventaire de l'avion (clic droit sur l'avion, si pris en charge).

### Modes de fumée :

* **Mode 1** – Jet central, consomme 1 teinture toutes les 10 secondes
* **Mode 2** – Jets latéraux, consomme 1 teinture toutes les 5 secondes
* **Mode 3** – Jets latéraux colorés différemment, 1 teinture par côté toutes les 10 secondes

La fumée n'apparaît que pendant le vol.

---

## Manuel

Un manuel (`pa28_color_trail:manual`) est inclus dans le mod. Il permet de consulter les instructions en jeu sur les modes et l'utilisation.

---

## Personnalisation

Le fichier `init.lua` contient une table `offset_config` pour tous les avions pris en charge, définissant :

```lua
["Nom de l'avion"] = {
    mode1 = {x = 0, y = 0, z = -2},  -- décalage du mode central
    mode2 = {x = 3, y = -0.2},      -- décalage des jets latéraux
    mode3 = {x = 3, y = -0.2},
}
```

Vous pouvez ajouter vos propres avions en complétant cette table.

---

## Limitations connues

* Ce mod repose sur l'accès externe à l'inventaire (`_inv`) fourni par le mod "Airutils" d'APercy
* Si un avion n'est pas pris en charge ou si une configuration manque, un avertissement s'affiche dans le chat.

---

## Crédits

* Mods d'avion originaux par APercy
* Système de fumée et intégration par Luffy0805

---

## Fin.
