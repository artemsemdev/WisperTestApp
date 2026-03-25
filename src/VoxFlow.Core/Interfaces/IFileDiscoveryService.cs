using VoxFlow.Core.Configuration;
using VoxFlow.Core.Models;

namespace VoxFlow.Core.Interfaces;

/// <summary>
/// Resolves batch input files into concrete per-file work items.
/// </summary>
public interface IFileDiscoveryService
{
    /// <summary>
    /// Discovers input files for a batch run, optionally limiting the number of files that will be processed.
    /// </summary>
    IReadOnlyList<DiscoveredFile> DiscoverInputFiles(BatchOptions batchOptions, int? maxFiles = null);
}
