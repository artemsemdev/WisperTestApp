namespace VoxFlow.Core.Models;

/// <summary>
/// Stores the normalized per-file result used for summary generation.
/// </summary>
public sealed record FileProcessingResult(
    string InputPath,
    string OutputPath,
    FileProcessingStatus Status,
    string? ErrorMessage,
    TimeSpan Duration,
    string? DetectedLanguage);

/// <summary>
/// Indicates the final status of a file processed during batch execution.
/// </summary>
public enum FileProcessingStatus
{
    Success,
    Failed,
    Skipped
}
