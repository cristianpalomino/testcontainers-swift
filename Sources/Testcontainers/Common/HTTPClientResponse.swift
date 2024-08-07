//
//  HTTPClientResponse.swift
//
//
//  Created by cristian on 7/08/24.
//

import Foundation
import NIOHTTP1
import NIO
import AsyncHTTPClient

final class HTTPClientResponse: HTTPClientResponseDelegate {
    var response: Data = Data()
    
    func didReceiveHead(task: HTTPClient.Task<Data>, _ head: HTTPResponseHead) -> EventLoopFuture<Void> {
        print(head.status)
        return task.eventLoop.makeSucceededFuture(())
    }
    
    func didReceiveBodyPart(task: HTTPClient.Task<Data>, _ buffer: ByteBuffer) -> EventLoopFuture<Void> {
        if
            let chunk = buffer.getString(at: 0, length: buffer.readableBytes),
            let data = buffer.getData(at: 0, length: buffer.readableBytes)
        {
            response.append(data)
            print(chunk)
        } else {
            print("Received chunk of data but could not decode to string.")
        }
        return task.eventLoop.makeSucceededFuture(())
    }
    
    func didFinishRequest(task: AsyncHTTPClient.HTTPClient.Task<Data>) throws -> Data {
        return response
    }
}
