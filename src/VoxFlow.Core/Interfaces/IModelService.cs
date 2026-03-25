using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;
using Whisper.net;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Manages Whisper model availability and lifetime.
/// </summary>
public interface IModelService
{
    /// <summary>
    /// Returns a ready-to-use Whisper factory, downloading or loading the configured model as needed.
    /// </summary>
    Task<WhisperFactory> GetOrCreateFactoryAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns model metadata without mutating the configured model file.
    /// </summary>
    ModelInfo InspectModel(TranscriptionOptions options);
}
