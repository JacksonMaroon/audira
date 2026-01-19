import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("formattingStyle") private var formattingStyleRaw = FormattingStyle.sentencePerLine.rawValue
    @AppStorage("paragraphSentenceCount") private var paragraphSentenceCount = 3
    @AppStorage("wrapWidth") private var wrapWidth = 80
    @AppStorage("promptText") private var promptText = ""

    private var formattingStyle: FormattingStyle {
        FormattingStyle(rawValue: formattingStyleRaw) ?? .sentencePerLine
    }

    var body: some View {
        ZStack {
            AikoBackground()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(AikoTypography.title)
                        .foregroundColor(AikoPalette.textPrimary)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(PillButtonStyle(kind: .neutral))
                }

                Divider()
                    .background(AikoPalette.cardBorder)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Formatting")
                        .font(AikoTypography.subtitle)
                        .foregroundColor(AikoPalette.textSecondary)

                    Picker("Style", selection: Binding(
                        get: { formattingStyle },
                        set: { formattingStyleRaw = $0.rawValue }
                    )) {
                        ForEach(FormattingStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(AikoPalette.accent)

                    if formattingStyle == .paragraphs {
                        HStack {
                            Text("Sentences per paragraph")
                                .font(AikoTypography.body)
                                .foregroundColor(AikoPalette.textSecondary)
                            Spacer()
                            Stepper(
                                value: $paragraphSentenceCount,
                                in: 2...6
                            ) {
                                Text("\(paragraphSentenceCount)")
                                    .font(AikoTypography.body)
                                    .foregroundColor(AikoPalette.textPrimary)
                            }
                        }
                    }

                    if formattingStyle == .wrapped {
                        HStack {
                            Text("Wrap width")
                                .font(AikoTypography.body)
                                .foregroundColor(AikoPalette.textSecondary)
                            Spacer()
                            Stepper(
                                value: $wrapWidth,
                                in: 60...140,
                                step: 5
                            ) {
                                Text("\(wrapWidth)")
                                    .font(AikoTypography.body)
                                    .foregroundColor(AikoPalette.textPrimary)
                            }
                        }
                    }

                    Text("Applies to new transcriptions.")
                        .font(AikoTypography.bodyMuted)
                        .foregroundColor(AikoPalette.textMuted)
                }

                Divider()
                    .background(AikoPalette.cardBorder)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Prompt")
                        .font(AikoTypography.subtitle)
                        .foregroundColor(AikoPalette.textSecondary)
                    TextField("Optional prompt to bias transcription", text: $promptText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AikoPalette.pill)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AikoPalette.pillBorder, lineWidth: 1)
                        )
                    Text("Applies to new transcriptions.")
                        .font(AikoTypography.bodyMuted)
                        .foregroundColor(AikoPalette.textMuted)
                }
            }
            .padding(24)
            .frame(width: 520)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AikoPalette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AikoPalette.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 28, y: 12)
            .padding(32)
        }
    }
}
