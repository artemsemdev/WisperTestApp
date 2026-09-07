import Testing
@testable import VoxFlowMCP

@Suite("VoxFlowMCP module")
struct MCPModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(MCPModule.name == "VoxFlowMCP")
        #expect(MCPModule.coreVersion.isEmpty == false)
    }
}
