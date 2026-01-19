import AVFoundation
import Foundation

final class RecordingService: ObservableObject {
    @Published private(set) var isRecording = false
    private var recorder: AVAudioRecorder?
    private(set) var recordingURL: URL?

    func startRecording() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "recording-\(UUID().uuidString).wav"
        let url = tempDir.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.prepareToRecord()
        recorder.record()

        self.recorder = recorder
        self.recordingURL = url
        self.isRecording = true
    }

    func stopRecording() -> URL? {
        guard let recorder else { return nil }
        recorder.stop()
        self.recorder = nil
        self.isRecording = false
        return recordingURL
    }

    func discardRecording() {
        let url = stopRecording()
        if let url {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
    }
}
