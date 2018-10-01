//
//  RecordsViewController.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

private enum SegueId: String {
    case record
}

class RecordsViewController: UIViewController, FlowScene {

    weak var flowCoordinator: MainFlowCoordinator?
    var viewModel: RecordsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifier = segue.identifier,
            let segueId = SegueId(rawValue: identifier)
            else { return }
        
//        switch segueId {
//        case .record:
//            flowCoordinator?.prepareScene(for: .record(segue: segue, record: Record()))
//        }
    }
    
    private func bindUI() {
        
    }

}
