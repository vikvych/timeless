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

    @IBOutlet weak var currentTitleLabel: UILabel!
    @IBOutlet weak var currentProjectLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var startNewLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var controlView: RecordsControlView!

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
        
        switch segueId {
        case .record:
            let record = Record.init(id: "", createdAt: Date(), startedAt: Date(), endedAt: nil, title: nil, comment: nil, projectId: nil, project: nil)
            
            flowCoordinator?.prepareScene(for: .record(segue: segue, record: record))
        }
    }
    
    private func bindUI() {
        
    }

    @IBAction func toggleRecord(_ sender: Any) {
    }
    
    
}
