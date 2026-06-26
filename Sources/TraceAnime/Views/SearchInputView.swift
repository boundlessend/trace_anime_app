import SwiftUI
import UniformTypeIdentifiers

struct SearchInputView: View {
    @Binding var urlText: String

    let isSearching: Bool
    let language: AppLanguage
    let searchURL: () -> Void
    let searchClipboard: () -> Void
    let chooseFile: () -> Void
    let handleDrop: ([NSItemProvider]) -> Bool

    @State private var isDropTargeted: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField(t(.imageURL, language: language), text: $urlText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .liquidGlass(cornerRadius: 20, isActive: false)
                    .onSubmit(searchURL)

                Button(action: searchURL) {
                    Image(systemName: "arrow.right.circle.fill")
                }
                .help(t(.searchURL, language: language))
                .disabled(isSearching)
                .buttonStyle(TracePressButtonStyle())
            }

            HStack(spacing: 8) {
                Button(action: searchClipboard) {
                    Label(t(.clipboard, language: language), systemImage: "doc.on.clipboard")
                        .multilineTextAlignment(.center)
                }
                .disabled(isSearching)
                .buttonStyle(TracePressButtonStyle())

                Button(action: chooseFile) {
                    Label(t(.choose, language: language), systemImage: "folder")
                        .multilineTextAlignment(.center)
                }
                .disabled(isSearching)
                .buttonStyle(TracePressButtonStyle())
            }

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.4),
                        style: StrokeStyle(lineWidth: isDropTargeted ? 2.2 : 1.5, dash: [6])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isDropTargeted ? Color.accentColor.opacity(0.10) : Color.clear)
                    )

                VStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                        .font(.title2)
                        .scaleEffect(isDropTargeted ? 1.12 : 1.0)
                    Text(t(.dropImage, language: language))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 96)
            .liquidGlass(cornerRadius: 14, isActive: isDropTargeted)
            .scaleEffect(isDropTargeted ? 1.015 : 1.0)
            .animation(.easeInOut(duration: 0.16), value: isDropTargeted)
            .onDrop(
                of: [UTType.fileURL.identifier, UTType.image.identifier], isTargeted: $isDropTargeted,
                perform: handleDrop)
        }
    }
}

func makeURLInput(urlText: String) throws -> SearchInput {
    let trimmed: String = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
        throw AppError.emptyURL
    }

    guard let url: URL = URL(string: trimmed),
        let scheme: String = url.scheme?.lowercased(),
        scheme == "http" || scheme == "https"
    else {
        throw AppError.invalidURL(urlText)
    }

    return .imageURL(url)
}
