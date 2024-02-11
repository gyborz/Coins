//
//  Agent.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

class Agent {
    typealias ConversionMethod<T: Decodable, S> = (T) -> S

    static let jsonDecoder = JSONDecoder()

    func run<T: Decodable, S>(
        _ request: URLRequest?,
        with decoder: JSONDecoder = jsonDecoder,
        conversionMethod: @escaping ConversionMethod<T, S>
    ) async throws -> S {
        guard let request else { throw NetworkError.missingURL }
        let data = try await executeRequest(request)
        let typedData = try decoder.decode(T.self, from: data)
        return conversionMethod(typedData)
    }

    func run<T: Decodable>(_ request: URLRequest?, with decoder: JSONDecoder = jsonDecoder) async throws -> T {
        guard let request else { throw NetworkError.missingURL }
        let data = try await executeRequest(request)
        return try decoder.decode(T.self, from: data)
    }

    @discardableResult
    func run(_ request: URLRequest?) async throws -> Data {
        guard let request else { throw NetworkError.missingURL }
        return try await executeRequest(request)
    }

    @discardableResult
    private func executeRequest(_ request: URLRequest) async throws -> Data {
        let request = request

        let (data, response) = try await URLSession.shared.data(for: request)

        var responseString: String = "RESPONSE: \(response)"
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            responseString = responseString + ",\n\nBody: \(jsonResponse)"
        } catch {
            throw NetworkError.decodingFailed
        }

        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseMissing
        }

        print("DEBUG REQUEST:\n\(request.cURL(pretty: true))\n\(responseString)")

        guard 200 ... 299 ~= response.statusCode else {
            // todo handle error
            throw NetworkError.unknown
        }

        return data
    }
}
