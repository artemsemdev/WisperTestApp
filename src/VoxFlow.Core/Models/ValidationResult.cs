namespace VoxFlow.Core.Models;

/// <summary>
/// Aggregates all startup validation checks for a given configuration.
/// </summary>
public sealed record ValidationResult(
    string Outcome,
    bool CanStart,
    bool HasWarnings,
    string ResolvedConfigurationPath,
    IReadOnlyList<ValidationCheck> Checks);
