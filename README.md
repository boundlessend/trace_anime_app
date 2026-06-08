<p align="center">
  <img src="Assets/AppIconSource.png" alt="TraceAnime app icon" width="128">
</p>

<h1 align="center">TraceAnime</h1>

<p align="center">
  <strong>Language:</strong> EN | <a href="README.ru.md">RU</a> | <a href="README.fr.md">FR</a>
</p>

<p align="center">
  <strong>macOS menu bar anime frame search</strong>
</p>

<p align="center">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-111827">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-f05138">
  <img alt="License" src="https://img.shields.io/badge/license-BSD--3--Clause-2563eb">
</p>

TraceAnime sits in the macOS menu bar and finds anime scenes from an image or video frame through the [trace.moe](https://trace.moe/) API.

It accepts an image URL, the latest image from the clipboard, a dragged image, or a file selected from disk. Results include anime metadata, timestamps, previews, history, favorites, quota information, and multilingual UI.

## Features

- Menu bar-only macOS interface.
- Search by image URL, clipboard image, drag and drop, or local file.
- Inline preview playback for search results.
- Favorites and search history with the original searched image.
- trace.moe quota view and optional API token.
- English, Russian, and French UI.
- BSD 3-Clause open-source license.

## Requirements

- macOS 14 or later.
- Xcode Command Line Tools.
- Network access to `api.trace.moe`.

## Build

```bash
swift build
```

## Run as an app bundle

```bash
./script/build_and_run.sh
```

The script builds the SwiftPM executable, generates the app icon, creates an ad-hoc signed `dist/TraceAnime.app`, and opens it.

## Build a release DMG

```bash
./script/build_dmg.sh
```

The release script creates `dist/TraceAnime.dmg` with an ad-hoc signed app bundle and a drag-to-Applications layout.

## Install from GitHub Releases

This build uses ad-hoc signing. Since Apple has not notarized it and no Apple Developer ID certificate signs it, macOS Gatekeeper may block the first launch after you download the DMG from GitHub.

To open the app:

1. Download `TraceAnime.dmg` from Releases.
2. Open the DMG and drag `TraceAnime.app` to Applications.
3. In Finder, right-click `TraceAnime.app` and choose Open.
4. Confirm Open in the macOS security prompt.

You only need this on the first launch. Releases that open without this prompt require an Apple Developer ID certificate and Apple notarization.

## Verify

```bash
./script/build_and_run.sh --verify
```

## Notes

- The trace.moe token is optional and is stored in app settings.
- Generated build artifacts are ignored by Git.
- This project is not affiliated with trace.moe or AniList.

## License

TraceAnime is released under the [BSD 3-Clause License](LICENSE).
