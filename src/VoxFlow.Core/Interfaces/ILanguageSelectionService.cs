using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;
using Whisper.net;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Runs Whisper inference and chooses the best-supported language candidate for an audio sample.
/// </summary>
public interface ILanguageSelectionService
{
    /// <summary>
    /// Evaluates the configured language candidates and returns the accepted transcript segments for the winning language.
    /// </summary>
    Task<LanguageSelectionResult> SelectBestCandidateAsync(
        WhisperFactory factory,
        float[] audioSamples,
        TranscriptionOptions options,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}
