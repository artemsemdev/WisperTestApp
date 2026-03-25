using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Loads immutable runtime configuration for VoxFlow hosts.
/// </summary>
public interface IConfigurationService
{
    /// <summary>
    /// Loads transcription options from the default configuration source or an explicit override file.
    /// </summary>
    Task<TranscriptionOptions> LoadAsync(string? configurationPath = null);

    /// <summary>
    /// Returns the supported language list from the effective configuration.
    /// </summary>
    IReadOnlyList<SupportedLanguage> GetSupportedLanguages(string? configurationPath = null);
}
