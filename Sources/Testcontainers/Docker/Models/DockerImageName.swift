//
//  DockerImageName.swift
//
//
//  Created by cristian on 3/09/24.
//

import Foundation

public struct DockerImageName {

    public let name: String
    public let tag: String

    var conventionName: String {
        "\(name):\(tag)"
    }

    public init(image: String) throws {
        let items = image.split(separator: ":")
        guard
            items.count == 2,
            let name = items.first,
            let tag = items.last
        else {
            throw "Unable to retrieve \(image), use the next format <name>:<tag>"
        }

        self.name = String(name)
        self.tag = String(tag)
    }

    public init(name: String, tag: String) {
        self.name = name
        self.tag = tag
    }
}
