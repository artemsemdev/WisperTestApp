using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;
using Whisper.net;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Applies transcript-cleanup heuristics to raw Whisper segments.
/// </summary>
public interface ITranscriptionFilter
{
    /// <summary>
    /// Filters raw segment data for the supplied language and returns accepted and skipped segments with reasons.
    /// </summary>
    CandidateFilteringResult FilterSegments(
        SupportedLanguage language,
        IReadOnlyList<SegmentData> segments,
        TranscriptionOptions options);
}
