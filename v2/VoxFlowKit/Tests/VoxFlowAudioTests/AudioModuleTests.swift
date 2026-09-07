import Testing
@testable import VoxFlowAudio

@Suite("VoxFlowAudio module")
struct AudioModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(AudioModule.name == "VoxFlowAudio")
        #expect(AudioModule.coreVersion.isEmpty == false)
    }
}
