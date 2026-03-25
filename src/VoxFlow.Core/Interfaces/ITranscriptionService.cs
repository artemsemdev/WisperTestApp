using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Orchestrates the end-to-end transcription of a single input file.
/// </summary>
public interface ITranscriptionService
{
    /// <summary>
    /// Executes the single-file transcription pipeline and returns the result payload for the caller.
    /// </summary>
    Task<TranscribeFileResult> TranscribeFileAsync(
        TranscribeFileRequest request,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}
