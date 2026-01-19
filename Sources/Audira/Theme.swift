import AppKit
import SwiftUI

private func dynamicColor(light: NSColor, dark: NSColor) -> Color {
    Color(NSColor(name: nil) { appearance in
        let match = appearance.bestMatch(from: [.darkAqua, .aqua])
        return match == .darkAqua ? dark : light
    })
}

private func rgb(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double = 1.0) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

enum AikoPalette {
    static let backgroundTop = dynamicColor(
        light: rgb(0.96, 0.97, 0.98),
        dark: rgb(0.16, 0.18, 0.20)
    )
    static let backgroundBottom = dynamicColor(
        light: rgb(0.90, 0.92, 0.94),
        dark: rgb(0.12, 0.14, 0.16)
    )
    static let card = dynamicColor(
        light: rgb(0.97, 0.98, 0.99),
        dark: rgb(0.18, 0.20, 0.22)
    )
    static let cardBorder = dynamicColor(
        light: rgb(0.84, 0.86, 0.88),
        dark: rgb(0.28, 0.31, 0.35)
    )
    static let pill = dynamicColor(
        light: rgb(0.92, 0.94, 0.96),
        dark: rgb(0.22, 0.25, 0.28)
    )
    static let pillBorder = dynamicColor(
        light: rgb(0.82, 0.84, 0.87),
        dark: rgb(0.30, 0.33, 0.37)
    )
    static let textPrimary = dynamicColor(
        light: rgb(0.12, 0.13, 0.14),
        dark: rgb(0.89, 0.90, 0.91)
    )
    static let textSecondary = dynamicColor(
        light: rgb(0.34, 0.36, 0.38),
        dark: rgb(0.66, 0.68, 0.71)
    )
    static let textMuted = dynamicColor(
        light: rgb(0.48, 0.50, 0.53),
        dark: rgb(0.52, 0.55, 0.59)
    )
    static let accent = dynamicColor(
        light: rgb(0.66, 0.63, 0.90),
        dark: rgb(0.55, 0.53, 0.93)
    )
    static let accentMuted = dynamicColor(
        light: rgb(0.54, 0.51, 0.80),
        dark: rgb(0.45, 0.43, 0.74)
    )
    static let danger = dynamicColor(
        light: rgb(0.72, 0.23, 0.23),
        dark: rgb(0.73, 0.29, 0.29)
    )
    static let dangerMuted = dynamicColor(
        light: rgb(0.94, 0.82, 0.82),
        dark: rgb(0.55, 0.21, 0.21)
    )
    static let overlay = dynamicColor(
        light: rgb(0.0, 0.0, 0.0, 0.08),
        dark: rgb(0.0, 0.0, 0.0, 0.35)
    )
    static let progressTrack = dynamicColor(
        light: rgb(0.0, 0.0, 0.0, 0.08),
        dark: rgb(1.0, 1.0, 1.0, 0.08)
    )
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
