import SwiftUI

struct AnimeDetailView: View {
    let entry: AnimeEntry
    @State private var mediaEntry: Entry?
    @State private var isLoading = false
    
    var sortedEpisodes: [Episode] {
        mediaEntry?.episodes?.sorted { ($0.episodeNumber ?? 0) < ($1.episodeNumber ?? 0) } ?? []
    }
    
    // Improved Grid: Fixed size items to ensure consistent centering via padding
    let columns = [
        GridItem(.fixed(450), spacing: 40),
        GridItem(.fixed(450), spacing: 40),
        GridItem(.fixed(450), spacing: 40)
    ]
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: entry.media?.bannerImage ?? "")) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.black }
            .frame(maxWidth: .infinity, maxHeight: .infinity).blur(radius: 60).overlay(Color.black.opacity(0.8)).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 60) {
                        VStack(alignment: .leading, spacing: 30) {
                            Text(entry.media?.title?.userPreferred ?? "").font(.system(size: 70, weight: .black))
                            if let desc = entry.media?.description { 
                                Text(desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                                    .font(.system(size: 28)).foregroundColor(.white.opacity(0.7)).lineLimit(3).frame(maxWidth: 1000, alignment: .leading) 
                            }
                        }
                        Spacer()
                        AsyncImage(url: URL(string: entry.media?.coverImage?.large ?? "")) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Rectangle().fill(Color.white.opacity(0.1)) }
                        .frame(width: 300, height: 450).cornerRadius(10).shadow(radius: 20)
                    }
                    .padding(.horizontal, 100).padding(.top, 100).padding(.bottom, 60)
                    
                    VStack(alignment: .center, spacing: 40) { // Center the entire episodes section
                        HStack {
                            Text("Episodes").font(.system(size: 44, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 100)
                        
                        if isLoading { 
                            ProgressView().scaleEffect(2).padding(.top, 100) 
                        } else {
                            LazyVGrid(columns: columns, spacing: 40) {
                                ForEach(sortedEpisodes) { ep in
                                    NavigationLink(destination: PlayerView(mediaId: entry.mediaId ?? 0, episode: ep)) {
                                        EpisodeGridCard(episode: ep, fallbackImage: entry.media?.bannerImage ?? "")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 100)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        .task { await fetchMediaEntry() }
    }
    
    func fetchMediaEntry() async {
        isLoading = true
        do {
            let response: SeanimeResponse<Entry> = try await APIClient.shared.fetch(endpoint: "/api/v1/library/anime-entry/\(entry.mediaId ?? 0)")
            self.mediaEntry = response.data
        } catch { print(error) }
        isLoading = false
    }
}

struct EpisodeGridCard: View {
    let episode: Episode; let fallbackImage: String
    @Environment(\.isFocused) var isFocused
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack {
                AsyncImage(url: URL(string: fallbackImage)) { $0.resizable().aspectRatio(contentMode: .fill) } 
                placeholder: { Color.white.opacity(0.1) }
                .frame(width: 450, height: 250).clipped()
                
                Color.black.opacity(isFocused ? 0.1 : 0.4)
                
                if isFocused {
                    Image(systemName: "play.circle.fill").font(.system(size: 80)).foregroundColor(.white).shadow(radius: 10)
                } else {
                    Text("\(episode.episodeNumber ?? 0)").font(.system(size: 60, weight: .black)).foregroundColor(.white.opacity(0.5))
                }
            }
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isFocused ? Color.white : Color.clear, lineWidth: 6))
            .scaleEffect(isFocused ? 1.05 : 1.0)
            
            Text("\(episode.episodeNumber ?? 0). \(episode.episodeTitle ?? "Episode \(episode.episodeNumber ?? 0)")")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isFocused ? .white : .secondary)
                .lineLimit(1)
                .padding(.leading, 10)
        }
        .animation(.snappy(duration: 0.2), value: isFocused)
    }
}
