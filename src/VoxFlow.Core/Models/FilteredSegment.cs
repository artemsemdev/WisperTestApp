namespace VoxFlow.Core.Models;

/// <summary>
/// Represents a transcript segment that survived the filtering pipeline.
/// </summary>
public sealed record FilteredSegment(
    TimeSpan Start,
    TimeSpan End,
    string Text,
    double Probability);
