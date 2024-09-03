//
//  ImageParams.swift
//
//
//  Created by cristian on 3/09/24.
//

import Foundation

public struct ImageParams {
    
    public let name: String
    public let tag: String
    public let src: String?
    public let repo: String?
    
    public init(image: String, src: String?, repo: String?) throws {
        let items = image.split(separator: ":")
        guard let name = items.first, let tag = items.last else {
            throw "Unable to parse \(image), use the next format <name>:<tag>"
        }

        self.name = String(name)
        self.tag = String(tag)
        self.src = src
        self.repo = repo
    }
    
    public init(name: String, tag: String, src: String?, repo: String?) {
        self.name = name
        self.tag = tag
        self.src = src
        self.repo = repo
    }
}
