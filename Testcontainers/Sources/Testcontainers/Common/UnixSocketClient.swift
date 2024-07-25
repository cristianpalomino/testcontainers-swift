//
//  UnixSocketClient.swift
//
//
//  Created by cristian on 19/07/24.
//

import Foundation

final class UnixSocketClient {
    
    let host: String
    private var sockfd: Int32 = -1
    
    init(host: String = "/var/run/docker.sock") {
        self.host = host
    }
    
    func open() -> Bool {
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        
        var localPath = host
        let maxPathLength = MemoryLayout.size(ofValue: addr.sun_path) - 1
        if localPath.count > maxPathLength {
            localPath = String(localPath.prefix(maxPathLength))
        }
        
        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            localPath.withCString { cstr in
                strncpy(ptr, cstr, maxPathLength)
            }
        }
        
        sockfd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard sockfd >= 0 else {
            print("Socket creation failed")
            return false
        }
        
        let addrSize = socklen_t(MemoryLayout.size(ofValue: addr))
        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sockfd, $0, addrSize)
            }
        }
        guard result >= 0 else {
            print("Socket connection failed")
            Foundation.close(sockfd)
            sockfd = -1
            return false
        }
        return true
    }
    
    func close() {
        if sockfd >= 0 {
            _ = Foundation.close(sockfd)
            sockfd = -1
        }
    }
    
    func sendRequest(_ request: String) -> String? {
        guard sockfd >= 0 else {
            print("Socket is not open")
            return nil
        }
        
        let data = request.data(using: .utf8)!
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            _ = send(sockfd, ptr.baseAddress, data.count, 0)
        }
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = recv(sockfd, &buffer, buffer.count, 0)
        guard bytesRead > 0 else {
            print("Socket read failed")
            return nil
        }
        
        return String(bytes: buffer[0..<bytesRead], encoding: .utf8)
    }
    
    func streamRequest(_ request: String, chunkSize: Int = 1024, chunkHandler: (String) -> Void) {
        guard sockfd >= 0 else {
            print("Socket is not open")
            return
        }
        
        let data = request.data(using: .utf8)!
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            _ = send(sockfd, ptr.baseAddress, data.count, 0)
        }
        
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        while true {
            let bytesRead = recv(sockfd, &buffer, buffer.count, 0)
            guard bytesRead > 0 else {
                if bytesRead < 0 {
                    print("Socket read failed")
                }
                break
            }
            if let chunk = String(bytes: buffer[0..<bytesRead], encoding: .utf8) {
                chunkHandler(chunk)
            }
        }
    }
}
