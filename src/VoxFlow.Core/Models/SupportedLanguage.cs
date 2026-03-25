namespace VoxFlow.Core.Models;

/// <summary>
/// Declares a language candidate that the runtime is allowed to select.
/// </summary>
public sealed record SupportedLanguage(
    string Code,
    string DisplayName,
    int Priority = 0);
