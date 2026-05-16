import Foundation
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var collection: AnimeCollection?
    @Published var isLoading = false
    
    func fetchLibrary() async {
        isLoading = true
        do {
            let response: SeanimeResponse<AnimeCollection> = try await APIClient.shared.fetch(endpoint: "/api/v1/library/collection")
            self.collection = response.data
        } catch {}
        isLoading = false
    }
}
