import AppKit
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

enum AppStage {
    case idle
    case recording
    case transcribing
    case result
}

struct ContentView: View {
    @State private var stage: AppStage = .idle
    @State private var transcript: String = ""
    @State private var language: String = "English"
    @State private var isTargeted = false
    @State private var showingImporter = false
    @State private var showingSettings = false
    @State private var recordingStart: Date? = nil
    @State private var transcriptionTask: Task<Void, Never>? = nil
    @State private var alertMessage: String = ""
    @State private var showAlert = false
    @StateObject private var transcriptionService = TranscriptionService()
    @StateObject private var recordingService = RecordingService()
    @AppStorage("formattingStyle") private var formattingStyleRaw = FormattingStyle.sentencePerLine.rawValue
    @AppStorage("paragraphSentenceCount") private var paragraphSentenceCount = 3
    @AppStorage("wrapWidth") private var wrapWidth = 80
    @AppStorage("promptText") private var promptText = ""

    var body: some View {
        ZStack {
            AikoBackground()

            if stage == .result {
                TranscriptView(text: $transcript)
            } else {
                DropZoneView(
                    isTargeted: isTargeted,
                    onImport: { showingImporter = true },
                    onRecord: startRecording
                )
            }

            if stage == .recording {
                AikoPalette.overlay.ignoresSafeArea()
                RecordingCard(
                    deviceName: "MacBook Pro Microphone",
                    startDate: recordingStart,
                    onDiscard: discardRecording,
                    onTranscribe: transcribeRecording
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            if stage == .transcribing {
                TranscribingOverlay()
                    .transition(.opacity)
            }
        }
        .safeAreaInset(edge: .top) {
            AikoTopBar(
                stage: stage,
                language: language,
                onNew: resetSession,
                onRecord: startRecording,
                onStop: stopTranscription,
                onCopy: copyTranscript,
                onMore: { showingSettings = true },
                shareText: transcript
            )
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.audio, .movie],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    startTranscription(for: url)
                }
            case .failure:
                break
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted, perform: handleDrop(providers:))
        .animation(.easeInOut(duration: 0.2), value: stage)
        .alert("Audira", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
            guard let data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            DispatchQueue.main.async {
                startTranscription(for: url)
            }
        }
        return true
    }

    private func startRecording() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    showError("Microphone access denied. Enable it in System Settings > Privacy & Security.")
                    return
                }
                do {
                    try recordingService.startRecording()
                    recordingStart = Date()
                    stage = .recording
                } catch {
                    showError("Failed to start recording: \\(error.localizedDescription)")
                }
            }
        }
    }

    private func discardRecording() {
        recordingService.discardRecording()
        recordingStart = nil
        stage = .idle
    }

    private func transcribeRecording() {
        let url = recordingService.stopRecording()
        recordingStart = nil
        startTranscription(for: url)
    }

    private func startTranscription(for url: URL?) {
        guard let url else {
            showError("No audio file available to transcribe.")
            return
        }

        transcriptionTask?.cancel()
        transcriptionService.cancel()
        stage = .transcribing

        let prompt = promptText
        let style = formattingStyle
        let paragraphs = paragraphSentenceCount
        let wrap = wrapWidth

        transcriptionTask = Task.detached { [transcriptionService] in
            do {
                var config = TranscriptionConfig()
                if !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    config.promptText = prompt
                }
                let text = try await transcriptionService.transcribe(fileURL: url, config: config)
                if Task.isCancelled { return }
                await MainActor.run {
                    transcript = TextFormatter.format(
                        text,
                        style: style,
                        paragraphSentenceCount: paragraphs,
                        wrapWidth: wrap
                    )
                    stage = .result
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    stage = .idle
                    showError(error.localizedDescription)
                }
            }
        }
    }

    private func stopTranscription() {
        transcriptionTask?.cancel()
        transcriptionService.cancel()
        stage = .idle
    }

    private func resetSession() {
        transcriptionTask?.cancel()
        transcriptionService.cancel()
        transcript = ""
        stage = .idle
    }

    private func copyTranscript() {
        guard stage == .result, !transcript.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcript, forType: .string)
    }

    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    private var formattingStyle: FormattingStyle {
        FormattingStyle(rawValue: formattingStyleRaw) ?? .sentencePerLine
    }
}
