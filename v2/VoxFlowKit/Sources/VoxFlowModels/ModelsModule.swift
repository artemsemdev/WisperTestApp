import VoxFlowCore

/// VoxFlowModels — model catalog and store: download, resume, verify, free-space check, remove.
/// Filled in from phase 1. The enum exists so the module has a compiled symbol and a
/// declared dependency on VoxFlowCore from day one.
public enum ModelsModule {
    public static let name = "VoxFlowModels"
    public static let coreVersion = VoxFlowVersion.string
}
