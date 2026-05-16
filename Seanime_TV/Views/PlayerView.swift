import SwiftUI
import AVKit

struct PlayerView: View {
    let mediaId: Int; let episode: Episode
    @StateObject private var viewModel = PlayerViewModel()
    @State private var player: AVPlayer?; @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let player = player { 
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear { player.play() }
                    .onDisappear { player.pause() } 
            }
            else if let error = errorMessage { 
                VStack(spacing: 30) { 
                    Image(systemName: "video.slash.fill").font(.system(size: 80)).foregroundColor(.red)
                    Text("Direct Stream Failed").font(.title2).bold()
                    Text(error).font(.body).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal, 100)
                    Button("Retry") { Task { await prepare() } }.buttonStyle(.bordered)
                } 
            }
            else { 
                VStack(spacing: 30) { 
                    ProgressView().scaleEffect(2)
                    Text("Loading Stream...").font(.headline).foregroundColor(.secondary)
                } 
            }
        }
        .task { await prepare() }
    }
    
    func prepare() async {
        guard let path = episode.localFile?.path else { self.errorMessage = "File path not found"; return }
        isLoading = true; errorMessage = nil
        
        // Mode Direct: Exactly like VLC, we hit the raw file stream.
        if let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let streamURLString = "\(Constants.baseURL)/api/v1/directstream/stream?path=\(encodedPath)"
            
            if let url = URL(string: streamURLString) {
                print("VLC-Style Direct Play: \(streamURLString)")
                self.player = AVPlayer(url: url)
                self.isLoading = false
            } else { self.errorMessage = "Invalid Stream URL" }
        } else { self.errorMessage = "Failed to encode path" }
    }
}
