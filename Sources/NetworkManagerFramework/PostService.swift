//
//  PostService.swift
//  NetworkManagerFramework
//
//  Created by Despo on 29.11.24.
//

//
//  PostMethod.swift
//  test2
//
//  Created by Despo on 29.11.24.
//

import Foundation

public protocol PostServiceProtocol {
    func postData<T: Codable, U: Codable>(
        urlString: String,
        headers: [String: String]?,
        body: T
    ) async throws -> U
}

@available(iOS 15.0, *)
public final class PostService: PostServiceProtocol {
    
    public init() { }
    
    public func postData<T: Codable, U: Codable>(
        urlString: String,
        headers: [String: String]? = nil,
        body: T
    ) async throws -> U {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(body)
            urlRequest.httpBody = jsonData
        } catch {
            throw NetworkError.decodeError(error: error)
        }
        
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
            let responseData = try decoder.decode(U.self, from: data)
            return responseData
        } catch {
            throw NetworkError.decodeError(error: error)
        }
    }
}
