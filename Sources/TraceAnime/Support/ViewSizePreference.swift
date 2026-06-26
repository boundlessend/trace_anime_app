import SwiftUI

struct ViewSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeReaderView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ViewSizePreferenceKey.self, value: proxy.size)
        }
    }
}

struct TracePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .liquidGlass(cornerRadius: 12, isActive: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 1.07 : 1.0)
            .offset(y: configuration.isPressed ? -2.0 : 0.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.56), value: configuration.isPressed)
    }
}

struct LiquidGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let isActive: Bool

    @State private var hoverLocation: CGPoint = .zero
    @State private var isHovering: Bool = false

    func body(content: Content) -> some View {
        content
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(isHovering || isActive ? 0.34 : 0.18), lineWidth: 0.7)
                    .allowsHitTesting(false)
            }
            .overlay {
                GeometryReader { proxy in
                    let width: CGFloat = max(proxy.size.width, 1.0)
                    let height: CGFloat = max(proxy.size.height, 1.0)
                    let point: UnitPoint = UnitPoint(
                        x: max(min(hoverLocation.x / width, 1.0), 0.0),
                        y: max(min(hoverLocation.y / height, 1.0), 0.0)
                    )

                    ZStack {
                        RadialGradient(
                            colors: [
                                .white.opacity(isActive ? 0.22 : 0.14),
                                .cyan.opacity(isHovering ? 0.10 : 0.0),
                                .yellow.opacity(isHovering ? 0.08 : 0.0),
                                .clear,
                            ],
                            center: point,
                            startRadius: 0.0,
                            endRadius: max(width, height) * 0.92
                        )

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.18),
                                        .cyan.opacity(0.14),
                                        .yellow.opacity(0.12),
                                        .clear,
                                    ],
                                    center: point
                                ),
                                lineWidth: 0.9
                            )
                            .opacity(isHovering || isActive ? 1.0 : 0.0)
                    }
                    .opacity(isHovering || isActive ? 1.0 : 0.0)
                    .blendMode(.plusLighter)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .animation(.easeOut(duration: 0.34), value: hoverLocation)
                    .animation(.easeOut(duration: 0.24), value: isHovering)
                    .allowsHitTesting(false)
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoverLocation = location
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
            .animation(.easeOut(duration: 0.24), value: isHovering)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat, isActive: Bool) -> some View {
        modifier(LiquidGlassSurfaceModifier(cornerRadius: cornerRadius, isActive: isActive))
    }
}

struct GlassSegment<Value: Hashable>: Identifiable {
    let value: Value
    let title: String
    let systemImage: String?

    var id: Value {
        value
    }
}

struct GlassSegmentedControl<Value: Hashable>: View {
    @Binding var selection: Value

    let segments: [GlassSegment<Value>]
    let segmentWidth: CGFloat?

    init(selection: Binding<Value>, segments: [GlassSegment<Value>], segmentWidth: CGFloat? = nil) {
        self._selection = selection
        self.segments = segments
        self.segmentWidth = segmentWidth
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(segments) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection = segment.value
                    }
                } label: {
                    GlassSegmentLabel(title: segment.title, systemImage: segment.systemImage)
                        .modifier(GlassSegmentLabelFrame(width: segmentWidth))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundStyle(
                            selection == segment.value ? Color.yellow.opacity(0.94) : Color.primary.opacity(0.82)
                        )
                        .background {
                            if selection == segment.value {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .allowsHitTesting(false)
                            }
                        }
                        .liquidGlass(cornerRadius: 20, isActive: selection == segment.value)
                        .contentShape(Capsule())
                        .modifier(GlassSegmentButtonFrame(width: segmentWidth))
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                .buttonStyle(GlassBounceButtonStyle())
            }
        }
        .frame(maxWidth: segmentWidth == nil ? .infinity : nil)
        .padding(3)
        .liquidGlass(cornerRadius: 22, isActive: false)
    }
}

/// держит вкладки поиска и настроек в неизменной геометрии при открытии служебных вкладок
struct StaticGlassTabControl<Value: Hashable>: View {
    @Binding var selection: Value

    let segments: [GlassSegment<Value>]
    let segmentWidth: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            ForEach(segments) { segment in
                Button {
                    selection = segment.value
                } label: {
                    Text(segment.title)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: segmentWidth, height: 24)
                        .foregroundStyle(
                            selection == segment.value ? Color.yellow.opacity(0.94) : Color.primary.opacity(0.82)
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background {
                            if selection == segment.value {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .allowsHitTesting(false)
                            }
                        }
                        .liquidGlass(cornerRadius: 20, isActive: selection == segment.value)
                        .contentShape(Capsule())
                        .frame(width: segmentWidth + 20.0, height: 30)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                .buttonStyle(GlassBounceButtonStyle())
            }
        }
        .frame(
            width: (segmentWidth + 20.0) * CGFloat(segments.count) + 2.0 * CGFloat(max(segments.count - 1, 0)),
            height: 36
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct GlassSegmentLabelFrame: ViewModifier {
    let width: CGFloat?

    func body(content: Content) -> some View {
        if let width: CGFloat {
            content
                .frame(width: width)
                .frame(height: 24)
        } else {
            content
                .frame(maxWidth: .infinity)
                .frame(height: 24)
        }
    }
}

struct GlassSegmentButtonFrame: ViewModifier {
    let width: CGFloat?

    func body(content: Content) -> some View {
        if let width: CGFloat {
            content
                .frame(width: width + 20.0)
        } else {
            content
                .frame(maxWidth: .infinity)
        }
    }
}

struct GlassSegmentLabel: View {
    let title: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage: String {
                Image(systemName: systemImage)
            }

            Text(title)
                .font(.callout.weight(.medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.82)
        }
    }
}

struct GlassToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                configuration.label
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(.thinMaterial)
                        .frame(width: 44, height: 24)

                    Circle()
                        .fill(configuration.isOn ? Color.yellow.opacity(0.94) : Color.primary.opacity(0.72))
                        .frame(width: 18, height: 18)
                        .padding(.horizontal, 3)
                }
                .liquidGlass(cornerRadius: 14, isActive: configuration.isOn)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .liquidGlass(cornerRadius: 20, isActive: configuration.isOn)
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(GlassBounceButtonStyle())
    }
}

struct GlassBounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.07 : 1.0)
            .offset(y: configuration.isPressed ? -2.0 : 0.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.56), value: configuration.isPressed)
    }
}
