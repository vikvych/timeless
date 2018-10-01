//
//  FlowCoordinator.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

protocol FlowCoordinator {
    
    associatedtype DataSegue
    
    func prepareScene(for segue: DataSegue)
    
}

protocol FlowScene where Coordinator: FlowCoordinator {
    
    associatedtype Coordinator
    
    var flowCoordinator: Coordinator? { get set }
    
}
