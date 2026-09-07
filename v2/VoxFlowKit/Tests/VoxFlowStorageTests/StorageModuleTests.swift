import Testing
@testable import VoxFlowStorage

@Suite("VoxFlowStorage module")
struct StorageModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(StorageModule.name == "VoxFlowStorage")
        #expect(StorageModule.coreVersion.isEmpty == false)
    }
}
