namespace VoxFlow.Core.Models;

/// <summary>
/// Represents the current high-level state of the interactive desktop workflow.
/// </summary>
public enum AppState
{
    Ready,
    Running,
    Failed,
    Complete
}
