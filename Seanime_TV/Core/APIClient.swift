import Foundation

class APIClient {
    static let shared = APIClient()
    
    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(Constants.baseURL)\(endpoint)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        return try await request(endpoint: endpoint, method: "POST", body: body)
    }
    
    func patch<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        return try await request(endpoint: endpoint, method: "PATCH", body: body)
    }
    
    private func request<T: Decodable, U: Encodable>(endpoint: String, method: String, body: U) async throws -> T {
        guard let url = URL(string: "\(Constants.baseURL)\(endpoint)") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("API Error (\(httpResponse.statusCode)): \(errorMsg)")
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
