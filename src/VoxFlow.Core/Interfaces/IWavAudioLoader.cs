using VoxFlow.Core.Configuration;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Loads normalized sample data from the generated WAV file.
/// </summary>
public interface IWavAudioLoader
{
    /// <summary>
    /// Reads audio samples from the supplied WAV path and validates that the file matches the configured output format.
    /// </summary>
    Task<float[]> LoadSamplesAsync(
        string wavPath,
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);
}
