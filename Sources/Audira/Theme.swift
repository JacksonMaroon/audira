import SwiftUI

enum AikoPalette {
    static let backgroundTop = Color(red: 0.16, green: 0.18, blue: 0.20)
    static let backgroundBottom = Color(red: 0.12, green: 0.14, blue: 0.16)
    static let card = Color(red: 0.18, green: 0.20, blue: 0.22)
    static let cardBorder = Color(red: 0.28, green: 0.31, blue: 0.35)
    static let pill = Color(red: 0.22, green: 0.25, blue: 0.28)
    static let pillBorder = Color(red: 0.30, green: 0.33, blue: 0.37)
    static let textPrimary = Color(red: 0.89, green: 0.90, blue: 0.91)
    static let textSecondary = Color(red: 0.66, green: 0.68, blue: 0.71)
    static let textMuted = Color(red: 0.52, green: 0.55, blue: 0.59)
    static let accent = Color(red: 0.55, green: 0.53, blue: 0.93)
    static let accentMuted = Color(red: 0.45, green: 0.43, blue: 0.74)
    static let danger = Color(red: 0.73, green: 0.29, blue: 0.29)
    static let dangerMuted = Color(red: 0.55, green: 0.21, blue: 0.21)
    static let overlay = Color.black.opacity(0.35)
    static let progressTrack = Color.white.opacity(0.08)
}

enum AikoTypography {
    static let title = Font.system(size: 20, weight: .semibold)
    static let subtitle = Font.system(size: 12, weight: .medium)
    static let body = Font.system(size: 15, weight: .regular)
    static let bodyMuted = Font.system(size: 13, weight: .regular)
    static let big = Font.system(size: 22, weight: .semibold)
    static let hud = Font.system(size: 15, weight: .medium)
}

struct AikoBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [AikoPalette.backgroundTop, AikoPalette.backgroundBottom]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PillButtonStyle: ButtonStyle {
    enum Kind {
        case neutral
        case accent
        case danger
    }

    var kind: Kind = .neutral

    func makeBody(configuration: Configuration) -> some View {
        let colors = colorsForKind(kind)
        return configuration.label
            .font(AikoTypography.body)
            .foregroundColor(colors.text)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(colors.fill.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(colors.border, lineWidth: 1)
            )
    }

    private func colorsForKind(_ kind: Kind) -> (fill: Color, border: Color, text: Color) {
        switch kind {
        case .neutral:
            return (AikoPalette.pill, AikoPalette.pillBorder, AikoPalette.textPrimary)
        case .accent:
            return (AikoPalette.accent, AikoPalette.accentMuted, AikoPalette.textPrimary)
        case .danger:
            return (AikoPalette.dangerMuted, AikoPalette.danger, AikoPalette.textPrimary)
        }
    }
}

struct CircleIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(AikoPalette.textPrimary)
            .padding(10)
            .background(
                Circle()
                    .fill(AikoPalette.pill.opacity(configuration.isPressed ? 0.75 : 1.0))
            )
            .overlay(
                Circle()
                    .stroke(AikoPalette.pillBorder, lineWidth: 1)
            )
    }
}
