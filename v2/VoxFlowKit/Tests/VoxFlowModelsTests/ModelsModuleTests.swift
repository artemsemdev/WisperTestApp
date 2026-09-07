import Testing
@testable import VoxFlowModels
import VoxFlowCore

@Suite("VoxFlowModels module")
struct ModelsModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(ModelsModule.name == "VoxFlowModels")
        #expect(ModelsModule.coreVersion == VoxFlowVersion.string)
    }
}
