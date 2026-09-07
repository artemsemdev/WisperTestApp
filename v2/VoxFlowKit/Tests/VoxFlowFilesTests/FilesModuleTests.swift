import Testing
@testable import VoxFlowFiles
import VoxFlowCore

@Suite("VoxFlowFiles module")
struct FilesModuleTests {
    @Test("module links against VoxFlowCore")
    func linksCore() {
        #expect(FilesModule.name == "VoxFlowFiles")
        #expect(FilesModule.coreVersion == VoxFlowVersion.string)
    }
}
