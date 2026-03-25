using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Reads completed transcript files for downstream hosts and tooling.
/// </summary>
public interface ITranscriptReader
{
    /// <summary>
    /// Reads a transcript file and optionally truncates the returned content.
    /// </summary>
    Task<TranscriptReadResult> ReadAsync(
        string path,
        int? maxCharacters = null,
        CancellationToken cancellationToken = default);
}
