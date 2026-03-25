namespace VoxFlow.Core.Models;

/// <summary>
/// Represents a batch input file after discovery and path resolution.
/// </summary>
public sealed record DiscoveredFile(
    string InputPath,
    string OutputPath,
    string TempWavPath,
    DiscoveryStatus Status,
    string? SkipReason);

/// <summary>
/// Describes whether a discovered batch file is ready for processing or already excluded.
/// </summary>
public enum DiscoveryStatus
{
    Ready,
    Skipped
}
