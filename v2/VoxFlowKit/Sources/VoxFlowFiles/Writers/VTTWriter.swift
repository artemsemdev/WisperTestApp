import VoxFlowCore

enum VTTWriter: TranscriptWriter {
    static let format = OutputFormat.vtt
    static func render(_ document: TranscriptDocument, timestamps: Bool) -> String {
        "WEBVTT\n\n" + document.transcript.segments.map { segment in
            "\(TimeCode.vtt(segment.start)) --> \(TimeCode.vtt(segment.end))\n\(TranscriptRenderer.cleanText(segment))"
        }.joined(separator: "\n\n") + "\n"
    }
}
