import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings

    let language: AppLanguage

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            VStack(alignment: .center, spacing: 6) {
                Toggle(t(.cutBorders, language: language), isOn: $settings.cutBorders)
                    .toggleStyle(GlassToggleStyle())

                Text(t(.cutBordersHint, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .center, spacing: 6) {
                GlassSegmentedControl(
                    selection: $settings.previewSize,
                    segments: PreviewSize.allCases.map { size in
                        GlassSegment(value: size, title: size.title, systemImage: nil)
                    }
                )

                Text(t(.previewHint, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            GlassSegmentedControl(
                selection: $settings.language,
                segments: AppLanguage.allCases.map { language in
                    GlassSegment(value: language, title: language.title, systemImage: nil)
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.easeInOut(duration: 0.2), value: settings.language)
    }
}
