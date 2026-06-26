import Foundation

enum L10nKey: String {
    case searchTab
    case settingsTab
    case extraTab
    case imageURL
    case searchURL
    case clipboard
    case choose
    case dropImage
    case searching
    case openPreview
    case copyResult
    case openMAL
    case copyDetails
    case share
    case favorite
    case removeFavorite
    case more
    case history
    case favorites
    case clearHistory
    case deleteEntry
    case noHistory
    case noFavorites
    case restoreSearch
    case quit
    case cutBorders
    case cutBordersHint
    case launchAtLogin
    case mutePreview
    case preview
    case previewHint
    case historyHint
    case captureHotKeyHint
    case language
    case apiKey
    case anilistIDFilter
    case quota
    case checkingQuota
    case concurrency
    case priority
    case copyright
    case clearCache
    case updateAvailable
    case version
    case checkUpdates
    case upToDate
    case updateFailed
    case download
    case cancel
    case source
    case sourceClipboard
    case sourceImage
    case episode
    case episodeUnknown
    case cacheCleared
}

func t(_ key: L10nKey, language: AppLanguage) -> String {
    switch language {
    case .english:
        return englishText(key)
    case .russian:
        return russianText(key)
    case .french:
        return frenchText(key)
    }
}

private func englishText(_ key: L10nKey) -> String {
    switch key {
    case .searchTab:
        return "Search"
    case .settingsTab:
        return "Settings"
    case .extraTab:
        return "Extra"
    case .imageURL:
        return "Image URL"
    case .searchURL:
        return "Search URL"
    case .clipboard:
        return "Clipboard"
    case .choose:
        return "Choose"
    case .dropImage:
        return "Drop image here"
    case .searching:
        return "Searching"
    case .openPreview:
        return "Play preview"
    case .copyResult:
        return "Copy AniList link and open"
    case .openMAL:
        return "Copy MyAnimeList link and open"
    case .copyDetails:
        return "Copy details"
    case .share:
        return "Share"
    case .favorite:
        return "Add to favorites"
    case .removeFavorite:
        return "Remove from favorites"
    case .more:
        return "Show more"
    case .history:
        return "History"
    case .favorites:
        return "Favorites"
    case .clearHistory:
        return "Clear all"
    case .deleteEntry:
        return "Delete"
    case .noHistory:
        return "No searches yet"
    case .noFavorites:
        return "No favorites yet"
    case .restoreSearch:
        return "Open"
    case .quit:
        return "Quit"
    case .cutBorders:
        return "Cut borders"
    case .cutBordersHint:
        return "Crops frame borders before search; useful for letterboxed images."
    case .launchAtLogin:
        return "Launch at login"
    case .mutePreview:
        return "Mute preview"
    case .preview:
        return "Preview quality"
    case .previewHint:
        return "S/M/L changes downloaded preview size and load speed."
    case .historyHint:
        return "How many recent searches to keep in history."
    case .captureHotKeyHint:
        return "Global hotkey to capture a screen area and search."
    case .language:
        return "Language"
    case .apiKey:
        return "trace.moe token"
    case .anilistIDFilter:
        return "AniList ID filter"
    case .quota:
        return "Quota"
    case .checkingQuota:
        return "Checking quota"
    case .concurrency:
        return "Concurrent requests"
    case .priority:
        return "Priority"
    case .copyright:
        return "© boundlessend"
    case .clearCache:
        return "Clear cache"
    case .updateAvailable:
        return "Update available"
    case .version:
        return "Version"
    case .checkUpdates:
        return "Check for updates"
    case .upToDate:
        return "You have the latest version"
    case .updateFailed:
        return "Update check failed"
    case .download:
        return "Download"
    case .cancel:
        return "Cancel"
    case .source:
        return "Source"
    case .sourceClipboard:
        return "Clipboard"
    case .sourceImage:
        return "image"
    case .episode:
        return "Episode"
    case .episodeUnknown:
        return "Episode unknown"
    case .cacheCleared:
        return "Cache cleared"
    }
}

private func russianText(_ key: L10nKey) -> String {
    switch key {
    case .searchTab:
        return "Поиск"
    case .settingsTab:
        return "Настройки"
    case .extraTab:
        return "Дополнительно"
    case .imageURL:
        return "URL изображения"
    case .searchURL:
        return "Искать по URL"
    case .clipboard:
        return "Буфер"
    case .choose:
        return "Выбрать"
    case .dropImage:
        return "Перетащите изображение сюда"
    case .searching:
        return "Идёт поиск"
    case .openPreview:
        return "Воспроизвести превью"
    case .copyResult:
        return "Скопировать ссылку AniList и открыть"
    case .openMAL:
        return "Скопировать ссылку MyAnimeList и открыть"
    case .copyDetails:
        return "Скопировать данные"
    case .share:
        return "Поделиться"
    case .favorite:
        return "Добавить в избранное"
    case .removeFavorite:
        return "Убрать из избранного"
    case .more:
        return "Ещё"
    case .history:
        return "История"
    case .favorites:
        return "Избранное"
    case .clearHistory:
        return "Очистить всё"
    case .deleteEntry:
        return "Удалить"
    case .noHistory:
        return "История пуста"
    case .noFavorites:
        return "Избранного пока нет"
    case .restoreSearch:
        return "Открыть"
    case .quit:
        return "Выйти"
    case .cutBorders:
        return "Обрезать рамки"
    case .cutBordersHint:
        return "Обрезает поля кадра перед поиском; полезно для изображений с рамками."
    case .launchAtLogin:
        return "Запускать при входе"
    case .mutePreview:
        return "Без звука"
    case .preview:
        return "Качество превью"
    case .previewHint:
        return "S/M/L меняет размер загружаемого превью и скорость загрузки."
    case .historyHint:
        return "Сколько последних поисков хранить в истории."
    case .captureHotKeyHint:
        return "Глобальный хоткей для захвата области экрана и поиска."
    case .language:
        return "Язык"
    case .apiKey:
        return "token trace.moe"
    case .anilistIDFilter:
        return "Фильтр AniList ID"
    case .quota:
        return "Квота"
    case .checkingQuota:
        return "Проверка квоты"
    case .concurrency:
        return "Одновременные запросы"
    case .priority:
        return "Приоритет"
    case .copyright:
        return "© boundlessend"
    case .clearCache:
        return "Очистить кэш"
    case .updateAvailable:
        return "Доступно обновление"
    case .version:
        return "Версия"
    case .checkUpdates:
        return "Проверить обновления"
    case .upToDate:
        return "У вас последняя версия"
    case .updateFailed:
        return "Не удалось проверить обновления"
    case .download:
        return "Скачать"
    case .cancel:
        return "Отмена"
    case .source:
        return "Источник"
    case .sourceClipboard:
        return "буфер обмена"
    case .sourceImage:
        return "изображение"
    case .episode:
        return "Эпизод"
    case .episodeUnknown:
        return "Эпизод неизвестен"
    case .cacheCleared:
        return "Кэш очищен"
    }
}

private func frenchText(_ key: L10nKey) -> String {
    switch key {
    case .searchTab:
        return "Recherche"
    case .settingsTab:
        return "Réglages"
    case .extraTab:
        return "Extra"
    case .imageURL:
        return "URL de l'image"
    case .searchURL:
        return "Rechercher par URL"
    case .clipboard:
        return "Presse-papiers"
    case .choose:
        return "Choisir"
    case .dropImage:
        return "Déposez l'image ici"
    case .searching:
        return "Recherche en cours"
    case .openPreview:
        return "Lire l'aperçu"
    case .copyResult:
        return "Copier le lien AniList et ouvrir"
    case .openMAL:
        return "Copier le lien MyAnimeList et ouvrir"
    case .copyDetails:
        return "Copier les détails"
    case .share:
        return "Partager"
    case .favorite:
        return "Ajouter aux favoris"
    case .removeFavorite:
        return "Retirer des favoris"
    case .more:
        return "Afficher plus"
    case .history:
        return "Historique"
    case .favorites:
        return "Favoris"
    case .clearHistory:
        return "Tout effacer"
    case .deleteEntry:
        return "Supprimer"
    case .noHistory:
        return "Aucune recherche"
    case .noFavorites:
        return "Aucun favori"
    case .restoreSearch:
        return "Ouvrir"
    case .quit:
        return "Quitter"
    case .cutBorders:
        return "Rogner les bords"
    case .cutBordersHint:
        return "Rogne les bords avant la recherche; utile pour les images encadrées."
    case .launchAtLogin:
        return "Lancer à la connexion"
    case .mutePreview:
        return "Aperçu muet"
    case .preview:
        return "Qualité de l'aperçu"
    case .previewHint:
        return "S/M/L change la taille téléchargée et la vitesse de chargement."
    case .historyHint:
        return "Combien de recherches récentes conserver dans l'historique."
    case .captureHotKeyHint:
        return "Raccourci global pour capturer une zone de l'écran et rechercher."
    case .language:
        return "Langue"
    case .apiKey:
        return "token trace.moe"
    case .anilistIDFilter:
        return "Filtre AniList ID"
    case .quota:
        return "Quota"
    case .checkingQuota:
        return "Vérification du quota"
    case .concurrency:
        return "Requêtes simultanées"
    case .priority:
        return "Priorité"
    case .copyright:
        return "© boundlessend"
    case .clearCache:
        return "Vider le cache"
    case .updateAvailable:
        return "Mise à jour disponible"
    case .version:
        return "Version"
    case .checkUpdates:
        return "Vérifier les mises à jour"
    case .upToDate:
        return "Vous avez la dernière version"
    case .updateFailed:
        return "Échec de la vérification des mises à jour"
    case .download:
        return "Télécharger"
    case .cancel:
        return "Annuler"
    case .source:
        return "Source"
    case .sourceClipboard:
        return "presse-papiers"
    case .sourceImage:
        return "image"
    case .episode:
        return "Épisode"
    case .episodeUnknown:
        return "Épisode inconnu"
    case .cacheCleared:
        return "Cache vidé"
    }
}
