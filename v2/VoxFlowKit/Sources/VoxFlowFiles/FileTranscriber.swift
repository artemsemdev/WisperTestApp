import Foundation
import VoxFlowCore

/// Decode → (auto language) → transcribe → `TranscriptDocument`. One file per call.
public struct FileTranscriber: FileTranscribing {
    static let decodeShare = 0.05

    private let decoder: any AudioDecoding
    private let engine: any SpeechEngine
    private let modelID: String
    private let now: @Sendable () -> Date

    public init(decoder: any AudioDecoding, engine: any SpeechEngine, modelID: String,
                now: @escaping @Sendable () -> Date = { Date() }) {
        self.decoder = decoder
        self.engine = engine
        self.modelID = modelID
        self.now = now
    }

    public func transcribe(_ url: URL, options: TranscriptionOptions,
                           progress: @Sendable @escaping (Double) -> Void) async throws -> TranscriptDocument {
        let started = now()
        let audio: AudioSamples
        do {
            audio = try decoder.decode(url)
        } catch {
            throw Self.mapDecodingError(error)
        }
        progress(Self.decodeShare)

        var options = options
        do {
            if options.language == nil {
                options.language = try await engine.detectLanguage(in: audio).code
            }
            var segments: [TranscriptSegment] = []
            for try await event in engine.transcribe(audio, options: options) {
                switch event {
                case .segment(let segment): segments.append(segment)
                case .progress(let value): progress(Self.decodeShare + (1 - Self.decodeShare) * min(max(value, 0), 1))
                }
            }
            try Task.checkCancellation()
            progress(1)
            return TranscriptDocument(sourceURL: url, transcript: Transcript(segments: segments, language: options.language),
                                      modelID: modelID, audioDuration: audio.duration,
                                      processingTime: now().timeIntervalSince(started), createdAt: now())
        } catch SpeechEngineError.modelNotLoaded {
            throw FileTranscriptionError.noModelInstalled
        } catch SpeechEngineError.cancelled {
            throw FileTranscriptionError.cancelled
        } catch is CancellationError {
            throw FileTranscriptionError.cancelled
        } catch let error as FileTranscriptionError {
            throw error
        } catch {
            throw FileTranscriptionError.engineFailed(String(describing: error))
        }
    }

    /// `VoxFlowFiles` depends on Core only, so a concrete `AudioDecoding` error (e.g. `VoxFlowAudio`'s
    /// `AudioDecodingError`) can't be named or `catch`-matched here. Its cases are structurally
    /// well-known (`unsupportedType(String)`, `fileNotFound(URL)`, `decodeFailed(String)`), so a
    /// reflection-based match reproduces the same mapping without a module dependency.
    private static func mapDecodingError(_ error: Error) -> FileTranscriptionError {
        if let child = Mirror(reflecting: error).children.first, let label = child.label {
            switch (label, child.value) {
            case ("unsupportedType", let ext as String):
                return .unsupportedType(ext)
            case ("decodeFailed", let reason as String):
                return .decodeFailed(reason)
            case ("fileNotFound", let missing as URL):
                return .decodeFailed("file not found: \(missing.lastPathComponent)")
            default:
                break
            }
        }
        return .decodeFailed(String(describing: error))
    }
}
