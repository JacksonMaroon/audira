import Foundation
import SwiftUI

struct AikoTopBar: View {
    let stage: AppStage
    let language: String
    let onNew: () -> Void
    let onRecord: () -> Void
    let onStop: () -> Void
    let onCopy: () -> Void
    let onShare: () -> Void
    let onMore: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if stage == .result {
                Text(language)
                    .font(AikoTypography.subtitle)
                    .foregroundColor(AikoPalette.textSecondary)
            }

            Spacer()

            if stage == .result {
                ActionPill(onCopy: onCopy, onShare: onShare, onMore: onMore)
            }

            if stage == .transcribing {
                CircleIconButton(systemName: "stop.fill", action: onStop)
            }

            if stage == .result {
                CircleIconButton(systemName: "mic.fill", action: onRecord)
                CircleIconButton(systemName: "plus", action: onNew)
            }

            if stage == .idle || stage == .recording {
                CircleIconButton(systemName: "plus", action: onNew)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AikoPalette.backgroundTop.opacity(0.9))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.05)),
            alignment: .bottom
        )
    }
}

struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
        }
        .buttonStyle(CircleIconButtonStyle())
    }
}

struct ActionPill: View {
    let onCopy: () -> Void
    let onShare: () -> Void
    let onMore: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
            }
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
            }
            Button(action: onMore) {
                Image(systemName: "ellipsis")
            }
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(AikoPalette.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AikoPalette.pill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AikoPalette.pillBorder, lineWidth: 1)
        )
        .buttonStyle(.plain)
    }
}

struct DropZoneView: View {
    let isTargeted: Bool
    let onImport: () -> Void
    let onRecord: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isTargeted ? AikoPalette.accent : AikoPalette.cardBorder, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AikoPalette.card.opacity(0.25))
                )
                .shadow(color: Color.black.opacity(0.25), radius: 14, y: 6)

            VStack(spacing: 16) {
                Text("Drop Audio or Video File")
                    .font(AikoTypography.big)
                    .foregroundColor(AikoPalette.textSecondary)

                HStack(spacing: 12) {
                    Button("Import", action: onImport)
                        .buttonStyle(PillButtonStyle(kind: .neutral))
                    Button("Record", action: onRecord)
                        .buttonStyle(PillButtonStyle(kind: .neutral))
                }
            }
        }
        .frame(maxWidth: 520, maxHeight: 240)
        .padding(.horizontal, 80)
        .padding(.vertical, 80)
    }
}

struct TranscriptView: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .font(AikoTypography.body)
            .foregroundColor(AikoPalette.textPrimary)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .padding(.top, 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct RecordingCard: View {
    let deviceName: String
    let startDate: Date?
    let onDiscard: () -> Void
    let onTranscribe: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recording")
                        .font(AikoTypography.title)
                        .foregroundColor(AikoPalette.textPrimary)
                    Text(deviceName)
                        .font(AikoTypography.subtitle)
                        .foregroundColor(AikoPalette.textMuted)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 14) {
                HStack(spacing: 18) {
                    AudioLevelDots()
                    Image(systemName: "mic.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AikoPalette.danger)
                }

                RecordingTimer(startDate: startDate)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AikoPalette.textPrimary)
            }

            Spacer()

            Divider()
                .background(AikoPalette.cardBorder)

            HStack {
                Button("Discard", action: onDiscard)
                    .buttonStyle(PillButtonStyle(kind: .danger))
                Spacer()
                Button("Transcribe", action: onTranscribe)
                    .buttonStyle(PillButtonStyle(kind: .accent))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .frame(width: 520, height: 340)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AikoPalette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AikoPalette.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 28, y: 12)
    }
}

struct RecordingTimer: View {
    let startDate: Date?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            Text(formatElapsed(startDate: startDate, now: context.date))
        }
    }

    private func formatElapsed(startDate: Date?, now: Date) -> String {
        guard let startDate else { return "00:00:00" }
        let elapsed = max(0, Int(now.timeIntervalSince(startDate)))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct AudioLevelDots: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 6) {
                ForEach(0..<5) { index in
                    let phase = t * 2.3 + Double(index) * 0.6
                    let scale = 0.6 + 0.4 * abs(sin(phase))
                    Circle()
                        .fill(AikoPalette.danger)
                        .frame(width: 6, height: 6)
                        .scaleEffect(scale)
                        .opacity(0.35 + 0.65 * scale)
                }
            }
        }
    }
}

struct TranscribingOverlay: View {
    var body: some View {
        ZStack {
            AikoPalette.overlay.ignoresSafeArea()

            VStack(spacing: 0) {
                IndeterminateProgressBar()
                    .frame(width: 200, height: 6)
                    .padding(.top, 10)

                Spacer()

                VStack(spacing: 6) {
                    Text("Transcribing")
                        .font(AikoTypography.big)
                        .foregroundColor(AikoPalette.textSecondary)
                    Text("This may take a while")
                        .font(AikoTypography.bodyMuted)
                        .foregroundColor(AikoPalette.textMuted)
                }

                Spacer()
            }
        }
    }
}

struct IndeterminateProgressBar: View {
    @State private var offset: CGFloat = -0.35

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AikoPalette.progressTrack)
                Capsule()
                    .fill(AikoPalette.accent)
                    .frame(width: proxy.size.width * 0.35)
                    .offset(x: offset * proxy.size.width)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    offset = 0.65
                }
            }
        }
    }
}
