import AppKit
import SwiftUI

struct HistoryView: View {
    let history: [SearchHistoryEntry]
    let language: AppLanguage
    let openHistory: (SearchHistoryEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(t(.history, language: language))
                .font(.headline)

            if history.isEmpty {
                Text(t(.noHistory, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 18)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(history) { entry in
                            HStack(spacing: 10) {
                                SourceImageThumbnailView(sourceImage: entry.sourceImage)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(entry.title)
                                        .font(.callout.weight(.medium))
                                        .lineLimit(1)
                                    Text(displayDate(entry.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button(t(.restoreSearch, language: language)) {
                                    openHistory(entry)
                                }
                                .buttonStyle(TracePressButtonStyle())
                            }
                            .padding(10)
                            .liquidGlass(cornerRadius: 12, isActive: false)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: 360)
            }
        }
    }
}

struct FavoritesView: View {
    let favorites: [FavoriteResult]
    let settings: AppSettings
    let language: AppLanguage
    let toggleFavorite: (TraceMoeResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(t(.favorites, language: language))
                .font(.headline)

            if favorites.isEmpty {
                Text(t(.noFavorites, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 18)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(favorites) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                SearchSourceHeaderView(
                                    sourceImage: item.sourceImage, date: item.date, language: language)

                                SearchResultRowView(
                                    result: item.result,
                                    settings: settings,
                                    language: language,
                                    isFavorite: true,
                                    toggleFavorite: toggleFavorite
                                )
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: 360)
            }
        }
    }
}

struct SearchSourceHeaderView: View {
    let sourceImage: SearchImageSnapshot?
    let date: Date
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 8) {
            SourceImageThumbnailView(sourceImage: sourceImage)

            VStack(alignment: .leading, spacing: 2) {
                if let sourceImage: SearchImageSnapshot {
                    Text(displaySource(sourceImage: sourceImage, language: language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(displayLongDate(date, language: language))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 2)
    }
}

struct SourceImageThumbnailView: View {
    let sourceImage: SearchImageSnapshot?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(.thinMaterial)

            if let sourceImage: SearchImageSnapshot {
                if let data: Data = sourceImage.data,
                    let image: NSImage = NSImage(data: data)
                {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let url: URL = sourceImage.url {
                    CachedPreviewImageView(url: url)
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

func displayDate(_ date: Date) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func displayLongDate(_ date: Date, language: AppLanguage) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.locale = locale(language: language)
    formatter.dateFormat = "d MMMM, yyyy, HH:mm"
    return formatter.string(from: date)
}

func displaySource(sourceImage: SearchImageSnapshot, language: AppLanguage) -> String {
    let sourceTitle: String

    if sourceImage.sourceKind == .clipboard || sourceImage.filename == "clipboard.jpg" {
        sourceTitle = t(.sourceClipboard, language: language)
    } else if let url: URL = sourceImage.url {
        sourceTitle = url.absoluteString
    } else if sourceImage.filename.isEmpty {
        sourceTitle = t(.sourceImage, language: language)
    } else {
        sourceTitle = sourceImage.filename
    }

    return "\(t(.source, language: language)): \(sourceTitle)"
}

func locale(language: AppLanguage) -> Locale {
    switch language {
    case .english:
        return Locale(identifier: "en_US")
    case .russian:
        return Locale(identifier: "ru_RU")
    case .french:
        return Locale(identifier: "fr_FR")
    }
}
