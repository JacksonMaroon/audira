import Foundation

struct TranscriptionConfig {
    var sourceLang: String = "en"
    var targetLang: String = "en"
    var task: String = "transcribe"
    var pnc: Bool = true
    var modelPath: URL?
    var pythonPath: URL?
    var canaryRoot: URL?
}

enum TranscriptionError: LocalizedError {
    case missingPython(String)
    case missingModel(String)
    case processFailed(String)
    case emptyOutput(String)
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .missingPython(let message):
            return message
        case .missingModel(let message):
            return message
        case .processFailed(let message):
            return message
        case .emptyOutput(let message):
            return message
        case .invalidOutput:
            return "Transcription output was not recognized."
        }
    }
}

final class TranscriptionService: ObservableObject {
    private var process: Process?

    func transcribe(fileURL: URL, config: TranscriptionConfig) throws -> String {
        let pythonURL = resolvePythonPath(override: config.pythonPath)
        let modelURL = resolveModelPath(override: config.modelPath)

        guard FileManager.default.fileExists(atPath: pythonURL.path) else {
            throw TranscriptionError.missingPython("Python not found at \(pythonURL.path).")
        }
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            throw TranscriptionError.missingModel("Model not found at \(modelURL.path).")
        }

        let process = Process()
        process.executableURL = pythonURL
        process.currentDirectoryURL = resolveCanaryRoot(override: config.canaryRoot)
        var args = [
            "-m", "canary_mlx.cli", "main",
            "--model", modelURL.path,
            "--source-lang", config.sourceLang,
            "--target-lang", config.targetLang,
            "--task", config.task,
        ]
        args.append(config.pnc ? "--pnc" : "--no-pnc")
        args.append(fileURL.path)
        process.arguments = args

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()
        self.process = process
        process.waitUntilExit()
        self.process = nil

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

        if process.terminationStatus != 0 {
            let err = String(data: errData, encoding: .utf8) ?? "Unknown error."
            throw TranscriptionError.processFailed(err)
        }

        let output = String(data: outData, encoding: .utf8) ?? ""
        guard !output.isEmpty else {
            let err = String(data: errData, encoding: .utf8) ?? ""
            throw TranscriptionError.emptyOutput(err)
        }

        return parseTranscription(output: output)
    }

    func cancel() {
        process?.terminate()
        process = nil
    }

    private func parseTranscription(output: String) -> String {
        let lines = output.split(whereSeparator: \.isNewline)
        guard let last = lines.last else {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let colonIndex = last.firstIndex(of: ":") {
            let text = last[last.index(after: colonIndex)...]
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return last.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resolvePythonPath(override: URL?) -> URL {
        if let override { return override }
        if let env = ProcessInfo.processInfo.environment["CANARY_MLX_PYTHON"] {
            return URL(fileURLWithPath: env)
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("canary-mlx/.venv/bin/python")
    }

    private func resolveModelPath(override: URL?) -> URL {
        if let override { return override }
        if let env = ProcessInfo.processInfo.environment["CANARY_MODEL"] {
            return URL(fileURLWithPath: env)
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("canary-mlx/canary-1b-v2-mlx")
    }

    private func resolveCanaryRoot(override: URL?) -> URL? {
        if let override { return override }
        if let env = ProcessInfo.processInfo.environment["CANARY_MLX_ROOT"] {
            return URL(fileURLWithPath: env)
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let root = home.appendingPathComponent("canary-mlx")
        if FileManager.default.fileExists(atPath: root.path) {
            return root
        }
        return nil
    }
}
