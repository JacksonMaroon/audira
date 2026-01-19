import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Binding var formattingStyle: FormattingStyle
    @Binding var paragraphSentenceCount: Int
    @Binding var wrapWidth: Int

    var body: some View {
        ZStack {
            AikoBackground()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Formatting")
                        .font(AikoTypography.title)
                        .foregroundColor(AikoPalette.textPrimary)
                    Spacer()
                    Button("Done") {
                        isPresented = false
                    }
                    .buttonStyle(PillButtonStyle(kind: .neutral))
                }

                Divider()
                    .background(AikoPalette.cardBorder)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Style")
                        .font(AikoTypography.subtitle)
                        .foregroundColor(AikoPalette.textSecondary)

                    Picker("Style", selection: $formattingStyle) {
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
