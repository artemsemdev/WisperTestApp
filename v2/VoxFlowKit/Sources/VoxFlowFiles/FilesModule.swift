import VoxFlowCore

/// VoxFlowFiles — file queue, transcript writers (TXT/SRT/VTT/JSON/MD), export.
/// Filled in from phase 1. The enum exists so the module has a compiled symbol and a
/// declared dependency on VoxFlowCore from day one.
public enum FilesModule {
    public static let name = "VoxFlowFiles"
    public static let coreVersion = VoxFlowVersion.string
}
