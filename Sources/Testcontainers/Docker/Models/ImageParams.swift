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
    
    public init(name: String, tag: String, src: String?, repo: String?) {
        self.name = name
        self.tag = tag
        self.src = src
        self.repo = repo
    }
}
