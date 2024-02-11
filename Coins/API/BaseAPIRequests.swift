//
//  BaseAPIRequests.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

final class BaseAPIRequests {
    private let baseURL: URL

    init?(baseURL: URL?) {
        guard let baseURL else { return nil }
        self.baseURL = baseURL
    }

    func buildRequest(path: String,
                      urlParameters: [String: String] = [:],
                      queryItems: [URLQueryItem] = [],
                      method: HTTPMethod = .get,
                      headers: [String: String] = [:],
                      parameters: [String: Any] = [:],
                      singleParameter: Any? = nil,
                      encoding: ParameterEncoder = JSONParameterEncoder(),
                      interceptors: [URLRequestInterceptor] = []) -> URLRequest {
        var url = baseURL.appendingPathComponent(path)

        if !urlParameters.isEmpty {
            url = url.addingQueryParameters(urlParameters)
        }

        if !queryItems.isEmpty {
            url = url.addingQueryItems(queryItems)
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 30.0).apply {
            $0.allHTTPHeaderFields = headers
            $0.httpMethod = method.rawValue
            if method != .get {
                try? encoding.encode(urlRequest: &$0, with: parameters)
                if let singleParameter = singleParameter {
                    try? encoding.encodeSingleObject(urlRequest: &$0, with: singleParameter)
                }
            }
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return interceptors.reduce(request) { request, interceptor in
            interceptor.intercept(request: request)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: [String: Any]) throws
    func encodeSingleObject(urlRequest: inout URLRequest, with parameterObject: Any) throws
}

final class JSONParameterEncoder: ParameterEncoder {
    init() {}

    private let contentType = "Content-Type"

    func encode(urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        guard !parameters.isEmpty else { return }
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .fragmentsAllowed])
            urlRequest.httpBody = jsonAsData

            if urlRequest.value(forHTTPHeaderField: contentType) == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: contentType)
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }

    func encodeSingleObject(urlRequest: inout URLRequest, with parameterObject: Any) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameterObject, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData

            if urlRequest.value(forHTTPHeaderField: contentType) == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: contentType)
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}

enum NetworkError: Error {
    case encodingFailed
    case decodingFailed
    case missingURL
    case responseMissing
    case unknown
}

protocol URLRequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
}

extension URL {
    var queryItems: [URLQueryItem] {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }

    var queryParameters: [String: String] {
        Dictionary(grouping: queryItems) { $0.name }.compactMapValues { $0.first?.value }
    }

    func addingQueryParameters(_ parameters: [String: String]) -> URL {
        guard !parameters.isEmpty else { return self }
        var queryItems = self.queryItems
        for item in parameters {
            queryItems.append(URLQueryItem(name: item.key, value: item.value))
        }
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.apply {
            $0.queryItems = queryItems
        }.url ?? self
    }

    func addingQueryItems(_ items: [URLQueryItem]) -> URL {
        var queryItems = self.queryItems
        queryItems.append(contentsOf: items)

        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.apply {
            $0.queryItems = queryItems
        }.url ?? self
    }
}

extension URLRequest {
    func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"

        var cURL = "curl "
        var header = ""
        var data: String = ""

        if let httpHeaders = allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }

        if let bodyData = httpBody, let bodyString = String(data: bodyData, encoding: .utf8), !bodyString.isEmpty {
            data = "--bodyData '\(bodyString)'"
        }

        cURL += method + url + header + data

        return cURL
    }
}
