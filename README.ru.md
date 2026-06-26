<p align="center">
  <img src="Assets/AppIconSource.png" alt="иконка приложения TraceAnime" width="128">
</p>

<h1 align="center">TraceAnime</h1>

<p align="center">
  <strong>Язык:</strong> <a href="README.md">EN</a> | RU | <a href="README.fr.md">FR</a>
</p>

<p align="center">
  <strong>поиск аниме-кадров из menu bar macOS</strong>
</p>

<p align="center">
  <img alt="CI" src="https://github.com/boundlessend/trace_anime_app/actions/workflows/ci.yml/badge.svg">
  <img alt="macOS" src="https://img.shields.io/badge/macOS-14%2B-111827">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-f05138">
  <img alt="лицензия" src="https://img.shields.io/badge/license-BSD--3--Clause-2563eb">
</p>

TraceAnime живет в menu bar macOS и ищет аниме-сцены по изображению или кадру видео через API [trace.moe](https://trace.moe/).

Приложение принимает URL изображения, последнее изображение из буфера обмена, перетаскивание картинки в окно или файл, выбранный на диске. В результатах есть метаданные аниме, таймкоды, превью, история, избранное, информация по квоте и многоязычный интерфейс.

## Возможности

- Интерфейс только в menu bar macOS.
- Поиск по URL изображения, буферу обмена, drag and drop, локальному файлу или захвату области экрана через настраиваемый глобальный хоткей.
- Воспроизведение превью прямо в результатах поиска.
- Открытие совпадений на AniList или MyAnimeList, копирование данных результата, перетаскивание кадра наружу или «Поделиться».
- Избранное и история поисков (настраиваемый размер, удаление записи и очистка всей) с исходной картинкой.
- Просмотр квоты trace.moe и необязательный API token.
- Уведомление о доступности новой версии.
- Запуск при входе в систему.
- Интерфейс на английском, русском и французском.
- Открытая лицензия BSD 3-Clause.

## Требования

- macOS 14 или новее.
- Xcode Command Line Tools.
- Доступ к `api.trace.moe`.

## Сборка

```bash
swift build
```

## Запуск как app bundle

```bash
./script/build_and_run.sh
```

Скрипт собирает SwiftPM executable, генерирует иконку приложения, создает ad-hoc подписанное `dist/TraceAnime.app` и открывает его.

## Сборка release DMG

```bash
./script/build_dmg.sh
```

Скрипт создает `dist/TraceAnime.dmg` с ad-hoc подписанным app bundle и layout для перетаскивания в Applications.

## Установка из GitHub Releases

Эта сборка использует ad-hoc подпись. Apple не заверяла этот DMG, и Apple Developer ID сертификат его не подписывает, поэтому macOS Gatekeeper может заблокировать первый запуск после загрузки из GitHub.

Чтобы открыть приложение:

1. Скачайте `TraceAnime.dmg` из Releases.
2. Откройте DMG и перетащите `TraceAnime.app` в Applications.
3. В Finder нажмите правой кнопкой по `TraceAnime.app` и выберите «Открыть».
4. Подтвердите открытие в системном окне macOS.

Это нужно только для первого запуска. Релизы без такого окна требуют Apple Developer ID сертификат и заверение у Apple.

## Заметки

- Token trace.moe необязателен и хранится в настройках приложения.
- Сгенерированные build-артефакты игнорируются Git.
- Проект не связан с trace.moe или AniList.

## Лицензия

TraceAnime распространяется по [BSD 3-Clause License](LICENSE).
