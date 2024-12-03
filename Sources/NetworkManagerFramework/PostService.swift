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
        
        if headers?["Content-Type"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(body)
            urlRequest.httpBody = jsonData
        } catch {
            print("Encoding Error: \(error)")
            throw NetworkError.decodeError(error: error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.httpResponseError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("HTTP Error: Status code \(httpResponse.statusCode)")
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "No response body")")
            throw NetworkError.statusCodeError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(U.self, from: data)
            return responseData
        } catch {
            print("Decoding Error: \(error)")
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
            throw NetworkError.decodeError(error: error)
        }
    }
}
