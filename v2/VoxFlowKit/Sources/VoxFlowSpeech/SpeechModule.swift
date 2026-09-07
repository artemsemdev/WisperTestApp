import VoxFlowCore

/// VoxFlowSpeech — `SpeechEngine` implementations; `WhisperCppEngine` actor over whisper.cpp.
/// Filled in from phase 1. The enum exists so the module has a compiled symbol and a
/// declared dependency on VoxFlowCore from day one.
public enum SpeechModule {
    public static let name = "VoxFlowSpeech"
    public static let coreVersion = VoxFlowVersion.string
}
