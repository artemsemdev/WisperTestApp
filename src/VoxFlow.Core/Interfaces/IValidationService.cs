using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Executes startup validation checks against the effective transcription configuration.
/// </summary>
public interface IValidationService
{
    /// <summary>
    /// Runs the configured validation checks and returns a consolidated result.
    /// </summary>
    Task<ValidationResult> ValidateAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);
}
