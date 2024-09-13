//
//  HTTPClientResponse.swift
//
//
//  Created by cristian on 7/08/24.
//

import Logging
import Foundation
import NIOHTTP1
import NIOCore
import AsyncHTTPClient

final class HTTPClientResponse: HTTPClientResponseDelegate {
    
    let logger: Logger = Logger(label: String(describing: HTTPClientResponse.self))
    var response: Data = Data()
    
    func didReceiveHead(task: HTTPClient.Task<Data>, _ head: HTTPResponseHead) -> EventLoopFuture<Void> {
        switch head.status.code {
        case 200..<300:
            logger.info("Request succeeded with status: \(head.status)")
            return task.eventLoop.makeSucceededFuture(())
        case 300..<400:
            logger.warning("Request resulted in a redirection with status: \(head.status)")
            // Handle redirection if necessary
            return task.eventLoop.makeSucceededFuture(())
        case 400..<500:
            logger.error("Client error with status: \(head.status)")
            return task.eventLoop.makeFailedFuture("Client error with status: \(head.status)")
        case 500..<600:
            logger.error("Server error with status: \(head.status)")
            return task.eventLoop.makeFailedFuture("Server error with status: \(head.status)")
        default:
            logger.error("Unexpected status code: \(head.status)")
            return task.eventLoop.makeFailedFuture("Unexpected status code: \(head.status)")
        }
    }
    
    func didReceiveBodyPart(task: HTTPClient.Task<Data>, _ buffer: ByteBuffer) -> EventLoopFuture<Void> {
        var mutableBuffer = buffer
        if let chunk = buffer.getString(at: 0, length: buffer.readableBytes),
           let bytes = mutableBuffer.readBytes(length: buffer.readableBytes) {
            response.append(Data(bytes))
            logger.info("Chunk: \(chunk)")
        } else {
            logger.info("Received chunk of data but could not decode to string.")
        }
        return task.eventLoop.makeSucceededFuture(())
    }
    
    func didFinishRequest(task: AsyncHTTPClient.HTTPClient.Task<Data>) throws -> Data {
        return response
    }
    
    func didReceiveError(task: HTTPClient.Task<Data>, _ error: Error) {
        logger.error("Request failed with error: \(String(describing: error))")
    }
}
