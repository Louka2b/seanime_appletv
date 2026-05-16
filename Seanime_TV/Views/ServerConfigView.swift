import SwiftUI

struct ServerConfigView: View {
    @State private var ip: String = ""
    @Binding var isConfigured: Bool
    
    // Explicitly define the initializer to avoid ambiguity
    init(isConfigured: Binding<Bool>) {
        self._isConfigured = isConfigured
    }
    
    var body: some View {
        VStack(spacing: 50) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            VStack(spacing: 20) {
                Text("Connect to Seanime")
                    .font(.title2)
                    .bold()
                
                TextField("Server IP (e.g. 192.168.1.36)", text: $ip)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .frame(width: 600)
            }
            
            Button("Connect") {
                Constants.baseURL = "http://\(ip):43211"
                isConfigured = true
            }
            .disabled(ip.isEmpty)
        }
    }
}
