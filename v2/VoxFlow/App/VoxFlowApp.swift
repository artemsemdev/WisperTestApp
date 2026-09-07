import SwiftUI

@main
struct VoxFlowApp: App {
    var body: some Scene {
        Window("VoxFlow", id: MainWindowID.main) {
            MainWindow()
        }
        .defaultSize(width: 1120, height: 720)

        MenuBarExtra("VoxFlow", systemImage: "waveform") {
            MenuBarContent()
        }
    }
}
