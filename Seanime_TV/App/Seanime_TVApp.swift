import SwiftUI

@main
struct Seanime_TVApp: App {
    @State private var isConfigured = Constants.isConfigured
    
    var body: some Scene {
        WindowGroup {
            if isConfigured {
                DashboardView()
                    .environment(\.serverReset, { isConfigured = false })
            } else {
                ServerConfigView(isConfigured: $isConfigured)
            }
        }
    }
}

// Global reset key
private struct ServerResetKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var serverReset: () -> Void {
        get { self[ServerResetKey.self] }
        set { self[ServerResetKey.self] = newValue }
    }
}
