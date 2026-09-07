import Testing
@testable import VoxFlowStyling

@Suite("VoxFlowStyling module")
struct StylingModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(StylingModule.name == "VoxFlowStyling")
        #expect(StylingModule.coreVersion.isEmpty == false)
    }
}
