import Testing
@testable import VoxFlowSpeech
import VoxFlowCore

@Suite("VoxFlowSpeech module")
struct SpeechModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(SpeechModule.name == "VoxFlowSpeech")
        #expect(SpeechModule.coreVersion == VoxFlowVersion.string)
    }
}
