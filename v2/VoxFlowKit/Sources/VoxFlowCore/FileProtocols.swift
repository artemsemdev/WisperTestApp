import Foundation

/// Decodes a file to engine-ready samples (implemented by `AudioDecoder`).
public protocol AudioDecoding: Sendable {
    func decode(_ url: URL) throws -> AudioSamples
}

/// Reads a file's duration cheaply, without decoding (queue header, > 4 h confirmation).
public protocol AudioDurationProviding: Sendable {
    func duration(of url: URL) async throws -> TimeInterval
}

public enum FileTranscriptionError: Error, Equatable, Sendable {
    case unsupportedType(String)
    case decodeFailed(String)
    case noModelInstalled
    case engineFailed(String)
    case cancelled
}

/// Transcribes one file end to end; `progress` is 0…1.
public protocol FileTranscribing: Sendable {
    func transcribe(_ url: URL, options: TranscriptionOptions,
                    progress: @Sendable @escaping (Double) -> Void) async throws -> TranscriptDocument
}
