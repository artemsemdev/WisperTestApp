import Testing
@testable import VoxFlowSpeech

@Suite("VoxFlowSpeech module")
struct SpeechModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(SpeechModule.name == "VoxFlowSpeech")
        #expect(SpeechModule.coreVersion.isEmpty == false)
    }
}
