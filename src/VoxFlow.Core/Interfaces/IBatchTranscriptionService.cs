using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Orchestrates batch transcription across a directory of input files.
/// </summary>
public interface IBatchTranscriptionService
{
    /// <summary>
    /// Transcribes the files described by the request and returns an aggregated batch result.
    /// </summary>
    Task<BatchTranscribeResult> TranscribeBatchAsync(
        BatchTranscribeRequest request,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}
