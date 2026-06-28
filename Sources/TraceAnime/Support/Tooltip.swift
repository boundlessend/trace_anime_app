import SwiftUI

/// иконочная кнопка с нативной подсказкой и press-анимацией glass-стиля
struct TooltipIconButton: View {
    let text: String
    let systemImage: String
    let fontSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: fontSize))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(GlassBounceButtonStyle())
        .help(text)
    }
}
