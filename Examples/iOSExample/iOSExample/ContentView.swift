//
//  GetEndpointView.swift
//  iOSExample
//
//  Created by cristian on 16/11/24.
//

import SwiftUI

enum HTTPError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

final class HTTPClient {
    
    let host: String
    
    init(host: String = "https://httpbin.org", port: Int? = nil) {
        if let port = port {
            self.host = "\(host):\(port)"
        } else {
            self.host = host
        }
    }
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(host)\(endpoint)") else {
            throw HTTPError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw HTTPError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw HTTPError.decodingError(decodingError)
        } catch {
            throw HTTPError.networkError(error)
        }
    }
}

struct EchoResponse: Decodable {
    let args: [String: String]
    let headers: [String: String]
    let url: String
}

final class ViewModel: ObservableObject {
    let httpClient: HTTPClient
    @Published var headers: [String: String] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    var hostInfo: String {
        return httpClient.host
    }
    
    init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }
    
    @MainActor
    func fetchData() async {
        isLoading = true
        do {
            let response: EchoResponse = try await httpClient.get(endpoint: "/get")
            headers = response.headers
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Host Information")) {
                    Text(viewModel.hostInfo)
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Section(header: Text("Headers")) {
                    ForEach(Array(viewModel.headers.keys.sorted()), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text(viewModel.headers[key] ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("/get")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .refreshable {
                await viewModel.fetchData()
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    ContentView()
}
