using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Persists a batch-processing summary in a human-readable format.
/// </summary>
public interface IBatchSummaryWriter
{
    /// <summary>
    /// Writes the final batch summary for the supplied file results.
    /// </summary>
    Task WriteAsync(
        string summaryPath,
        IReadOnlyList<FileProcessingResult> results,
        CancellationToken cancellationToken = default);
}
