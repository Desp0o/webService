// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case httpResponseError
    case statusCodeError(statusCode: Int)
    case noData
    case decodeError(error: Error)
}

@available(macOS 12.0, *)
public protocol NetworkServiceProtocol {
    func fetchData<T: Codable>(urlString: String) async throws -> T
}

public final class NetworkService: NetworkServiceProtocol {
    
    public init() { }
    
    @available(macOS 12.0, *)
    public func fetchData<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.httpResponseError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCodeError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let fetchedData = try decoder.decode(T.self, from: data)
            return fetchedData
        } catch {
            throw NetworkError.decodeError(error: error)
        }
    }
}
