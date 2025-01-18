import Foundation

public struct Info: Decodable, Sendable {
    let ServerVersion: String
    let OperatingSystem: String
    let MemTotal: Int64
    let Labels: [String]
}