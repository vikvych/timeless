//
//  Entity.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

typealias ID = String

protocol Entity: Hashable, Codable {
    
    var id: ID { get }
    
}
