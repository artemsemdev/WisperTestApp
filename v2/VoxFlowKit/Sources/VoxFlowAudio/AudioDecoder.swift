@preconcurrency import AVFoundation
import Foundation
import VoxFlowCore

public enum AudioDecodingError: Error, Equatable, Sendable {
    case fileNotFound(URL)
    /// The extension is not one VoxFlow accepts (design MW-06x: "Not an audio or video file").
    case unsupportedType(String)
    /// AVFoundation could not open or read the file ("Couldn't decode this file").
    case decodeFailed(String)
}

/// Decodes any AVFoundation-readable audio/video file to `AudioSamples` (16 kHz mono Float32).
public struct AudioDecoder: Sendable {
    /// Extensions accepted on drop (design MW-06 / MW-06x), lowercase.
    public static let supportedExtensions: Set<String> = [
        "mp3", "wav", "m4a", "aac", "flac", "aiff", "aif", "caf", "mp4", "mov", "m4v",
    ]

    /// Input frames read from the file per input-block invocation; bounds memory for
    /// multi-hour files.
    private static let chunkFrames: AVAudioFrameCount = 65_536

    public init() {}

    public func decode(_ url: URL) throws -> AudioSamples {
        let ext = url.pathExtension.lowercased()
        guard Self.supportedExtensions.contains(ext) else { throw AudioDecodingError.unsupportedType(ext) }
        guard FileManager.default.fileExists(atPath: url.path) else { throw AudioDecodingError.fileNotFound(url) }

        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            throw AudioDecodingError.decodeFailed(error.localizedDescription)
        }

        let target = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: AudioSamples.sampleRate,
                                   channels: 1, interleaved: false)!
        guard let converter = AVAudioConverter(from: file.processingFormat, to: target) else {
            throw AudioDecodingError.decodeFailed("no converter from \(file.processingFormat) to 16 kHz mono")
        }

        let ratio = AudioSamples.sampleRate / file.processingFormat.sampleRate
        var output: [Float] = []
        output.reserveCapacity(Int(Double(file.length) * ratio) + 1024)

        // The input block reads the next chunk directly from `file` each time the converter
        // asks for more; all state (the read cursor) lives on `file` itself, so nothing
        // mutable needs to be captured by this @Sendable closure.
        let outputCapacity = AVAudioFrameCount(Double(Self.chunkFrames) * ratio) + 1024
        var conversionError: NSError?

        conversionLoop: while true {
            let outputBuffer = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: outputCapacity)!
            let status = converter.convert(to: outputBuffer, error: &conversionError) { _, outStatus in
                let chunk = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: Self.chunkFrames)!
                guard let _ = try? file.read(into: chunk, frameCount: Self.chunkFrames), chunk.frameLength > 0 else {
                    outStatus.pointee = .endOfStream
                    return nil
                }
                outStatus.pointee = .haveData
                return chunk
            }
            if let conversionError { throw AudioDecodingError.decodeFailed(conversionError.localizedDescription) }

            output.append(contentsOf: UnsafeBufferPointer(start: outputBuffer.floatChannelData![0],
                                                         count: Int(outputBuffer.frameLength)))

            switch status {
            case .haveData:
                continue conversionLoop
            case .endOfStream, .inputRanDry:
                break conversionLoop
            case .error:
                throw AudioDecodingError.decodeFailed("conversion failed")
            @unknown default:
                break conversionLoop
            }
        }

        guard !output.isEmpty else {
            throw AudioDecodingError.decodeFailed("no audio data decoded")
        }

        return AudioSamples(output)
    }
}
