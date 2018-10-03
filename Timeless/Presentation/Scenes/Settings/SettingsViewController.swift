//
//  SettingsViewController.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, FlowScene {
    
    @IBOutlet weak var generateButton: UIButton!
    
    weak var flowCoordinator: MainFlowCoordinator?
    var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindUI()
    }
    
    private func bindUI() {
        generateButton.reactive.tap
            .bind(to: self) { me, _ in
                me.viewModel.generateSampleData()
        }
    }

}
