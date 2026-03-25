using VoxFlow.Core.Configuration;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Converts source audio into the normalized WAV format expected by the transcription pipeline.
/// </summary>
public interface IAudioConversionService
{
    /// <summary>
    /// Converts the supplied input file into a WAV file that matches the configured transcription settings.
    /// </summary>
    Task ConvertToWavAsync(
        string inputPath,
        string outputPath,
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Verifies that the configured ffmpeg executable can be launched successfully.
    /// </summary>
    Task<bool> ValidateFfmpegAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);
}
