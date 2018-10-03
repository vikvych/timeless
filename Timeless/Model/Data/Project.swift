//
//  Project.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

struct Project: Entity {
    
    let id: ID
    let createdAt: Date
    var name: String
    var records: [Record]
    
}

extension Project {
    
    struct Relations: OptionSet {
        let rawValue: Int
        
        static let records = Relations(rawValue: 1 << 0)
    }
    
}

extension Project {
    
    init(name: String) {
        self.name = name
        id = UUID().uuidString
        createdAt = Date()
        records = []
    }
    
}
