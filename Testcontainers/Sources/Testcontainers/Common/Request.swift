//
//  Request.swift
//
//
//  Created by cristian on 17/07/24.
//

import Foundation

extension String: Error { }

struct EmptyBody: Encodable { }

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Request {
    associatedtype Body: Encodable
    associatedtype Response
    
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get set }
    var query: [String: String]? { get set }
    var headers: [String: String] { get }
    var body: Body? { get }
    var decoder: (Data?) throws -> Response { get }
    
    func make() throws -> URLRequest?
}

extension Request where Response: Decodable {
    
    var decoder: (Data?) throws -> Response {
        return { data in
            guard let data = data else {
                throw "Response Data not found"
            }
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: data)
        }
    }
}

extension Request where Response == String {
    
    var decoder: (Data?) throws -> Response {
        return { data in
            guard let data = data else {
                throw "Response Data not found"
            }
            guard let string = String(data: data, encoding: .utf8) else {
                throw "Unable to decode Data to String"
            }
            return string
        }
    }
}

extension Request where Response == Data {
    
    var decoder: (Data?) throws -> Response {
        return { data in
            guard let data = data else {
                throw "Response Data not found"
            }
            return data
        }
    }
}

extension Request {
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    var parameters: [String: String]? {
        get { return nil }
        set { }
    }
    
    var query: [String: String]? {
        get { return nil }
        set { }
    }
    
    func make() throws -> URLRequest? {
        var pathWithParams = path
        
        if let parameters = parameters {
            for (key, value) in parameters {
                pathWithParams = pathWithParams
                    .replacingOccurrences(of: ":\(key)", with: value)
            }
        }
        
        guard var url = URL(string: "\(host)\(pathWithParams)") else {
            return nil
        }
        
        if let query = query {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = query.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            url = urlComponents?.url ?? url
        }
        
        let proxy = "http://localhost:8080/proxy?url="
        guard let proxyUrl = URL(string: "\(proxy)\(url.absoluteString)") else {
            return nil
        }
        
        var request = URLRequest(url: proxyUrl)
        request.httpMethod = method.rawValue
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
}

extension URLSession {
    
    func send<T: Request>(_ request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        do {
            guard let urlRequest = try request.make() else {
                completion(.failure("Unable to create the URLRequest"))
                return
            }
            
            URLSession.shared.configuration.timeoutIntervalForRequest = 60
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                }
                
                do {
                    let response = try request.decoder(data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

extension Request {
    
    func toUnix() throws -> String {
        switch method {
        case .get, .delete:
            return "\(method.rawValue) \(path) HTTP/1.41\r\nHost: \(host)\r\n\r\n"
        case .post:
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(body)
                
                guard let string = String(data: data, encoding: .utf8) else {
                    throw "\(#function)\nUnable to create string body"
                }
                
                return "\(method.rawValue) \(path) HTTP/1.41\r\nHost: \(host)\r\nContent-Length: \(string.count)\r\n\r\n\(string)"
            } catch {
                throw error
            }
        default:
            throw "\(#function)\nMethod not supported"
        }
    }
}
