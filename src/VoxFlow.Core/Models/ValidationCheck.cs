namespace VoxFlow.Core.Models;

/// <summary>
/// Describes the outcome of a single startup validation check.
/// </summary>
public sealed record ValidationCheck(
    string Name,
    ValidationCheckStatus Status,
    string Details);

/// <summary>
/// Represents the status of an individual startup validation check.
/// </summary>
public enum ValidationCheckStatus
{
    Passed,
    Warning,
    Failed,
    Skipped
}
