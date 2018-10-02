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
    case settings(segue: UIStoryboardSegue)
}

class MainFlowCoordinator: NSObject {
    
    @IBOutlet weak var navigationController: UINavigationController!
    
    private lazy var coverTransition = CoverTransition(headerColor: .white)
    private let dependencyContainer = DependencyContainer.createDefault()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UIView.appearance().tintColor = .red
        
        let recordsViewController = navigationController.topViewController as! RecordsViewController
        recordsViewController.flowCoordinator = self
        recordsViewController.viewModel = RecordsViewModel(with: dependencyContainer)
    }
    
}

extension MainFlowCoordinator: FlowCoordinator {
    
    func prepareScene(for segue: MainFlowSegue) {
        switch segue {
        case let .record(segue, record):
            let viewController = segue.destination as! RecordDetailsViewController
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = coverTransition
            viewController.flowCoordinator = self
            viewController.viewModel = RecordDetailsViewModel(dataModelContainer: dependencyContainer, record: record)
        case let .settings(segue):
            let viewController = segue.destination as! SettingsViewController
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = coverTransition
            viewController.flowCoordinator = self
            viewController.viewModel = SettingsViewModel(dataModelContainer: dependencyContainer)
        }
    }
    
}
