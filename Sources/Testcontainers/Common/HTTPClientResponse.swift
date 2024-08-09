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
    
    private lazy var logger: Logger = {
        var logger = Logger(label: #file)
        logger.logLevel = .trace
        return logger
    }()
    
    var response: Data = Data()
    
    func didReceiveHead(task: HTTPClient.Task<Data>, _ head: HTTPResponseHead) -> EventLoopFuture<Void> {
        logger.info("\(head.status)")
        return task.eventLoop.makeSucceededFuture(())
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
        logger.error("Request failed with error: \(error.localizedDescription)")
    }
}
