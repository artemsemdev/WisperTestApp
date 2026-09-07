import Testing
@testable import VoxFlowDictation

@Suite("VoxFlowDictation module")
struct DictationModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(DictationModule.name == "VoxFlowDictation")
        #expect(DictationModule.coreVersion.isEmpty == false)
    }
}
