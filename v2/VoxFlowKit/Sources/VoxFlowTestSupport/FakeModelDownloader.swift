import Foundation
import VoxFlowCore

/// Serves in-memory bytes per URL, appends to an existing partial file, and can fail once
/// mid-transfer to simulate going offline (design ONB-04a / ST-03o).
public actor FakeModelDownloader: ModelDownloading {
    public struct Call: Equatable, Sendable {
        public let url: URL
        public let resumedFrom: Int64
    }

    private var payloads: [URL: Data] = [:]
    /// Fail with `.offline` after writing this many *new* bytes on the next call, then clear.
    public var failAfterBytes: Int64?
    public private(set) var calls: [Call] = []
    public var chunkSize = 64 * 1024

    public init() {}

    public func serve(_ data: Data, at url: URL) { payloads[url] = data }
    public func setFailAfterBytes(_ bytes: Int64?) { failAfterBytes = bytes }
    public func setChunkSize(_ n: Int) { chunkSize = n }

    public func download(_ url: URL, to destination: URL, progress: @Sendable @escaping (Int64, Int64) -> Void) async throws {
        guard let data = payloads[url] else { throw DownloadError.http(status: 404) }
        let existing = (try? FileManager.default.attributesOfItem(atPath: destination.path)[.size] as? Int64) ?? 0
        calls.append(Call(url: url, resumedFrom: existing))
        if !FileManager.default.fileExists(atPath: destination.path) {
            FileManager.default.createFile(atPath: destination.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: destination)
        defer { try? handle.close() }
        try handle.seekToEnd()
        var written = existing
        var newBytes: Int64 = 0
        let total = Int64(data.count)
        var offset = Int(existing)
        while offset < data.count {
            // A real, timed suspension point between chunks: with unbounded stream buffering and no
            // per-chunk delay, the whole transfer can complete before a consumer's cancellation is
            // even requested, so a plain `Task.yield()` isn't enough to make cancellation land
            // mid-transfer. The delay is negligible at production chunk sizes (a handful of chunks)
            // and is what cancelKeepsPartial relies on with its small chunkSize.
            try await Task.sleep(for: .microseconds(200))
            try Task.checkCancellation()
            let end = min(offset + chunkSize, data.count)
            let chunk = data[offset..<end]
            try handle.write(contentsOf: chunk)
            offset = end
            written += Int64(chunk.count)
            newBytes += Int64(chunk.count)
            progress(written, total)
            if let limit = failAfterBytes, newBytes >= limit {
                failAfterBytes = nil
                throw DownloadError.offline(bytesWritten: written)
            }
        }
    }
}
