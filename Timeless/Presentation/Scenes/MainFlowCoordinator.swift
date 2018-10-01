//
//  MainFlowCoordinator.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

enum MainFlowSegue {
    case record(segue: UIStoryboardSegue, record: Record)
}

class MainFlowCoordinator: NSObject {
    
    @IBOutlet weak var navigationController: UINavigationController!
    
    let dependencyContainer = DependencyContainer.createDefault()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let recordsViewController = navigationController.topViewController as! RecordsViewController
        recordsViewController.viewModel = RecordsViewModel(with: dependencyContainer)
        recordsViewController.flowCoordinator = self
    }
    
}

extension MainFlowCoordinator: FlowCoordinator {
    
    func prepareScene(for segue: MainFlowSegue) {
        switch segue {
        case let .record(segue, record):
            break
        }
    }
    
}
