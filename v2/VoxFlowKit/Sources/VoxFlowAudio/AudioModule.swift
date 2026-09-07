import VoxFlowCore

/// VoxFlowAudio — file decode to 16 kHz mono Float32; microphone capture; RMS for the waveform.
/// Filled in from phase 1. The enum exists so the module has a compiled symbol and a
/// declared dependency on VoxFlowCore from day one.
public enum AudioModule {
    public static let name = "VoxFlowAudio"
    public static let coreVersion = VoxFlowVersion.string
}
