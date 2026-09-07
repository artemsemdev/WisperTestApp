import Testing
@testable import VoxFlowFiles

@Suite("VoxFlowFiles module")
struct FilesModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(FilesModule.name == "VoxFlowFiles")
        #expect(FilesModule.coreVersion.isEmpty == false)
    }
}
