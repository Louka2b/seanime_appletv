import Foundation

struct Constants {
    private static let urlKey = "seanime_url"
    static var baseURL: String {
        get { UserDefaults.standard.string(forKey: urlKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: urlKey) }
    }
    static var isConfigured: Bool { !baseURL.isEmpty }
    static var appLanguage: String = "English"
}
