import Foundation
import Combine

@MainActor
class PlayerViewModel: ObservableObject {
    private let clientId = "appletv-\(UUID().uuidString.prefix(4))"
    
    func startTracking(mediaId: Int, episodeNumber: Int) async {
        // Tracking logic implemented via API call if needed
    }
    
    func syncProgress() async {
        // Sync logic implemented via API call if needed
    }
}
