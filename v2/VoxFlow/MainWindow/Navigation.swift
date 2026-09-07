import SwiftUI

/// The selected sidebar page, shared by the main window and the app-level ⌘1–7 commands.
@Observable @MainActor
final class Navigation {
    var page: SidebarPage = .default
}
