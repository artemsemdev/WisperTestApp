namespace VoxFlow.Core.Models;

/// <summary>
/// Represents transcript content read back from a completed output file.
/// </summary>
public sealed record TranscriptReadResult(
    string Path,
    string Content,
    long TotalLength,
    bool WasTruncated);
