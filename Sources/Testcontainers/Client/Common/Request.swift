//
//  Request.swift
//
//
//  Created by cristian on 17/07/24.
//

import Foundation

extension String: Error { }

struct EmptyBody: Encodable { }
struct EmptyResponse: Decodable { }

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Request {
    associatedtype Body
    associatedtype Response
    
    var proxy: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get set }
    var query: [String: String]? { get set }
    var headers: [String: String] { get }
    var body: Body? { get }
    
    var decode: (Data?) -> Response { get }
    var encode: (Body?) -> Data? { get }
}

extension Request {
    
    var proxy: String {
        return "http://localhost:8001/proxy?url="
    }
    
    var host: String {
        return "http://localhost:2377"
    }
}

extension Request where Response: Decodable {
    
    var decode: (Data?) -> Response {
        return { data in
            guard let data = data else {
                fatalError("Unable to decode the received data.")
            }
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(Response.self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension Request where Response == String {
    
    var decode: (Data?) -> Response {
        return { data in
            guard let data = data else {
                fatalError("Unable to decode the received data.")
            }
            guard let string = String(data: data, encoding: .utf8) else {
                fatalError("Unable to decode the received data to string.")
            }
            return string
        }
    }
}

extension Request where Response == Data {
    
    var decode: (Data?) throws -> Response {
        return { data in
            guard let data = data else {
                fatalError("Unable to decode the received data.")
            }
            return data
        }
    }
}

extension Request where Body: Encodable {
    
    var encode: (Body?) -> Data? {
        return { body in
            guard let body = body else {
                return nil
            }
            return try? JSONEncoder().encode(body)
        }
    }
}

extension Request {
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "User-Agent": "tc-swift/1.0.0",
            "X-tc-sid": ""
        ]
    }
    
    var parameters: [String: String]? {
        get { return nil }
        set { }
    }
    
    var query: [String: String]? {
        get { return nil }
        set { }
    }
    
    var body: Body? {
        return nil
    }
    
    var encoder: (Body?) throws -> Data? {
        return { _ in
            return nil
        }
    }
}

extension Request {
    
    private func applyParamsIfAvailable() -> URL? {
        var pathWithParams = path
        if let parameters = parameters {
            for (key, value) in parameters {
                pathWithParams = pathWithParams.replacingOccurrences(of: ":\(key)", with: value)
            }
        }
        return URL(string: "\(host)\(pathWithParams)")
    }
    
    private func applyQueriesIfAvailable(to url: URL) -> URL? {
        if let query = query {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = query.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            return urlComponents?.url
        }
        return url
    }
    
    private func applyProxyIfDefined(to url: URL) -> URL? {
        guard let url = URL(string: "\(proxy)\(url.absoluteString)") else {
            return nil
        }
        return url
    }
    
    func make() -> URLRequest {
        guard 
            let urlWithParams = applyParamsIfAvailable(),
            let urlWithQueries = applyQueriesIfAvailable(to: urlWithParams)
        else {
            fatalError("Unable to create a valid URL.")
        }
        
        guard let url = applyProxyIfDefined(to: urlWithQueries) else {
            fatalError("Unable to apply the proxy to the given url.")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = encode(body)
        return request
    }
}

extension URLSession {
    
    func send<T: Request>(_ request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        URLSession.shared.configuration.timeoutIntervalForRequest = 60
        URLSession.shared.dataTask(with: request.make()) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            let response = request.decode(data)
            completion(.success(response))
        }.resume()
    }
}

extension Request {
    
    //    func toUnix() throws -> String {
    //        switch method {
    //        case .get, .delete:
    //            return "\(method.rawValue) \(path) HTTP/1.41\r\nHost: \(host)\r\n\r\n"
    //        case .post:
    //            do {
    //                let encoder = JSONEncoder()
    //                encoder.outputFormatting = .prettyPrinted
    //                let data = try encoder.encode(body)
    //
    //                guard let string = String(data: data, encoding: .utf8) else {
    //                    throw "\(#function)\nUnable to create string body"
    //                }
    //
    //                return "\(method.rawValue) \(path) HTTP/1.41\r\nHost: \(host)\r\nContent-Length: \(string.count)\r\n\r\n\(string)"
    //            } catch {
    //                throw error
    //            }
    //        default:
    //            throw "\(#function)\nMethod not supported"
    //        }
    //    }
}
