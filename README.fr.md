<p align="center">
  <img src="Assets/AppIconSource.png" alt="icône de l'application TraceAnime" width="128">
</p>

<h1 align="center">TraceAnime</h1>

<p align="center">
  <strong>Langue:</strong> <a href="README.md">EN</a> | <a href="README.ru.md">RU</a> | FR
</p>

<p align="center">
  <strong>recherche d'images d'anime depuis la barre de menu macOS</strong>
</p>

<p align="center">
  <img alt="CI" src="https://github.com/boundlessend/trace_anime_app/actions/workflows/ci.yml/badge.svg">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-111827">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-f05138">
  <img alt="licence" src="https://img.shields.io/badge/license-BSD--3--Clause-2563eb">
</p>

TraceAnime vit dans la barre de menu macOS et retrouve des scènes d'anime à partir d'une image ou d'une image vidéo via l'API [trace.moe](https://trace.moe/).

L'application accepte une URL d'image, la dernière image du presse-papiers, une image glissée dans la fenêtre ou un fichier choisi sur le disque. Les résultats incluent les métadonnées de l'anime, les horodatages, les aperçus, l'historique, les favoris, les informations de quota et une interface multilingue.

## Fonctionnalités

- Interface uniquement dans la barre de menu macOS.
- Recherche par URL d'image, presse-papiers, glisser-déposer ou fichier local.
- Lecture d'aperçu directement dans les résultats.
- Favoris et historique avec l'image recherchée.
- Affichage du quota trace.moe et token API optionnel.
- Interface en anglais, russe et français.
- Licence open source BSD 3-Clause.

## Prérequis

- macOS 14 ou version ultérieure.
- Xcode Command Line Tools.
- Accès réseau à `api.trace.moe`.

## Compilation

```bash
swift build
```

## Lancer comme app bundle

```bash
./script/build_and_run.sh
```

Le script compile l'exécutable SwiftPM, génère l'icône de l'application, crée `dist/TraceAnime.app` signé en ad-hoc et l'ouvre.

## Créer un DMG de release

```bash
./script/build_dmg.sh
```

Le script de release crée `dist/TraceAnime.dmg` avec un app bundle signé en ad-hoc et une fenêtre de glisser-déposer vers Applications.

## Installation depuis GitHub Releases

Cette version utilise une signature ad-hoc. Apple ne l'a pas notariée et aucun certificat Apple Developer ID ne la signe, donc macOS Gatekeeper peut bloquer le premier lancement après le téléchargement du DMG depuis GitHub.

Pour ouvrir l'application:

1. Téléchargez `TraceAnime.dmg` depuis Releases.
2. Ouvrez le DMG et glissez `TraceAnime.app` dans Applications.
3. Dans Finder, faites un clic droit sur `TraceAnime.app` et choisissez Ouvrir.
4. Confirmez l'ouverture dans la boîte de dialogue de sécurité macOS.

Vous ne faites cela qu'au premier lancement. Les releases sans cette alerte exigent un certificat Apple Developer ID et une notarisation Apple.

## Vérification

```bash
./script/build_and_run.sh --verify
```

## Notes

- Le token trace.moe est optionnel et stocké dans les réglages de l'application.
- Les artefacts générés sont ignorés par Git.
- Ce projet n'est pas affilié à trace.moe ou AniList.

## Licence

TraceAnime est distribué sous la [licence BSD 3-Clause](LICENSE).
