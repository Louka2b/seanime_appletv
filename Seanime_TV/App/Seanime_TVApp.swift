import SwiftUI

@main
struct Seanime_TVApp: App {
    @State private var isConfigured = Constants.isConfigured
    
    var body: some Scene {
        WindowGroup {
            if isConfigured, let url = URL(string: Constants.baseURL) {
                SeanimeWebView(url: url)
                    .edgesIgnoringSafeArea(.all)
                    .onLongPressGesture { // Reset IP if needed
                        isConfigured = false
                        Constants.baseURL = ""
                    }
            } else {
                ServerConfigView(isConfigured: $isConfigured)
            }
        }
    }
}
