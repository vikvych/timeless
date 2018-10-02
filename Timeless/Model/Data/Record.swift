//
//  Record.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

struct Record: Entity {
    
    let id: ID
    let createdAt: Date
    var startedAt: Date
    var endedAt: Date?
    var title: String?
    var comment: String?
    var projectId: ID?
    var project: Project?

}

extension Record {
    
    struct Relations: OptionSet {
        let rawValue: Int
        
        static let project = Relations(rawValue: 1 << 0)
    }
    
}
