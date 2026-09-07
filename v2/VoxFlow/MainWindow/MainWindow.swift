import SwiftUI

/// Main window content (design 1c): sidebar + detail, 1120×720 by default, ⌘1…⌘7 jump to pages.
struct MainWindow: View {
    @State private var selection: SidebarPage = .default

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
        } detail: {
            PlaceholderPageView(page: selection)
        }
        .frame(minWidth: 900, minHeight: 600)
        .background {
            // Hidden buttons give ⌘1…⌘7 without a custom menu; replaced by a Commands menu in phase 4.
            ForEach(SidebarPage.allCases) { page in
                Button("") { selection = page }
                    .keyboardShortcut(KeyEquivalent(Character("\(page.shortcutNumber)")), modifiers: .command)
                    .hidden()
            }
        }
    }
}
