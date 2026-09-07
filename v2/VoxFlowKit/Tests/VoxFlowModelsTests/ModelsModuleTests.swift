import Testing
@testable import VoxFlowModels

@Suite("VoxFlowModels module")
struct ModelsModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(ModelsModule.name == "VoxFlowModels")
        #expect(ModelsModule.coreVersion.isEmpty == false)
    }
}
