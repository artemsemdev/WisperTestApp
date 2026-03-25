namespace VoxFlow.Core.Models;

/// <summary>
/// Represents the outcome of a batch transcription run.
/// </summary>
public sealed record BatchTranscribeResult(
    int TotalFiles,
    int Succeeded,
    int Failed,
    int Skipped,
    string? SummaryFilePath,
    TimeSpan TotalDuration,
    IReadOnlyList<BatchFileResult> Results);

/// <summary>
/// Captures the result of a single file within a batch transcription run.
/// </summary>
public sealed record BatchFileResult(
    string InputPath,
    string OutputPath,
    string Status,
    string? ErrorMessage,
    TimeSpan Duration,
    string? DetectedLanguage);
