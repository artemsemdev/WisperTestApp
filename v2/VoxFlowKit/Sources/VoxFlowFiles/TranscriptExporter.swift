import Foundation
import VoxFlowCore

/// Writes rendered transcripts next to each other in one folder (design: "Save to ~/Transcripts").
public struct TranscriptExporter: Sendable {
    public static var defaultDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Transcripts", isDirectory: true)
    }

    public let directory: URL

    public init(directory: URL = TranscriptExporter.defaultDirectory) { self.directory = directory }

    @discardableResult
    public func export(_ document: TranscriptDocument, format: OutputFormat, timestamps: Bool) throws -> URL {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = availableURL(baseName: document.baseName, ext: format.fileExtension)
        try TranscriptRenderer.render(document, format: format, timestamps: timestamps).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    public func exportAll(_ document: TranscriptDocument, formats: [OutputFormat], timestamps: Bool) throws -> [OutputFormat: URL] {
        var urls: [OutputFormat: URL] = [:]
        for format in formats { urls[format] = try export(document, format: format, timestamps: timestamps) }
        return urls
    }

    /// `name.ext`, then `name-2.ext`, `name-3.ext`, … — never overwrites.
    func availableURL(baseName: String, ext: String) -> URL {
        var candidate = directory.appendingPathComponent(baseName).appendingPathExtension(ext)
        var counter = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = directory.appendingPathComponent("\(baseName)-\(counter)").appendingPathExtension(ext)
            counter += 1
        }
        return candidate
    }
}
