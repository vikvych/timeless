//
//  RecordsViewController.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

private let placeholderAlpha: CGFloat = 0.4

private enum SegueId: String {
    case record
    case settings
}

class RecordsViewController: UIViewController, FlowScene {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controlView: RecordsControlView!
    @IBOutlet weak var currentTitleLabel: UILabel!
    @IBOutlet weak var currentProjectLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var startNewLabel: UILabel!
    @IBOutlet weak var actionButton: ActionButton!
    
    weak var flowCoordinator: MainFlowCoordinator?
    
    var viewModel: RecordsViewModel!
    
    private var selectedRecord: Record? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.setImageScaleToParent(0.6)
        bindUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = tableView.contentInset
        
        insets.bottom = controlView.bounds.height
        
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let identifier = segue.identifier,
            let segueId = SegueId(rawValue: identifier)
            else { return }
        
        switch segueId {
        case .record:
            let record = selectedRecord ?? viewModel.currentRecordInstance ?? viewModel.createNew()
            
            selectedRecord = nil
            flowCoordinator?.prepareScene(for: .record(segue: segue, record: record))
        case .settings:
            flowCoordinator?.prepareScene(for: .settings(segue: segue))
        }
    }
    
    @IBAction func unwindToRecords(_ segue: UIStoryboardSegue) {}
    
    private func bindUI() {
        viewModel.recordsInfo()
            .bind(to: tableView) { [weak self] records, indexPath, tableView -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: RecordCell.identifier, for: indexPath) as! RecordCell
                let record = records[indexPath.row]
                
                cell.titleLabel.text = record.title
                cell.projectLabel.text = record.projectName
                cell.timeLabel.text = record.dateString
                cell.durationLabel.text = record.durationString
                cell.titleLabel.alpha = record.isTitlePlaceholder ? placeholderAlpha : 1.0
                cell.projectLabel.alpha = record.isProjectPlaceholder ? placeholderAlpha : 1.0
                cell.playButton.reactive.tap
                    .observe(with: { _ in self?.viewModel.createNew(from: record.record) })
                    .dispose(in: cell.onReuseBag)

                return cell
        }
        
        viewModel.isCurrentRecordHidden()
            .bind(to: self) { me, isHidden in
                UIView.transition(with: me.controlView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    me.currentTitleLabel.isHidden = isHidden
                    me.currentProjectLabel.isHidden = isHidden
                    me.currentDurationLabel.isHidden = isHidden
                    me.startNewLabel.isHidden = !isHidden
                }, completion: nil)
        }
        
        viewModel.currentRecord()
            .bind(to: self) { me, record in
                me.currentTitleLabel.text = record.title
                me.currentProjectLabel.text = record.projectName
                me.currentTitleLabel.alpha = record.isTitlePlaceholder ? placeholderAlpha : 1.0
                me.currentProjectLabel.alpha = record.isProjectPlaceholder ? placeholderAlpha : 1.0
        }
        
        viewModel.timer()
            .bind(to: self) { me, durationString in
                me.currentDurationLabel.text = durationString
        }
        
        viewModel.isRecording()
            .bind(to: self) { me, isRecording in
                me.actionButton.isSelected = isRecording
        }
        
        tableView.reactive.selectedRowIndexPath
            .with(latestFrom: viewModel.recordsInfo()) { (indexPath: IndexPath, event: ObservableArrayEvent) -> Record in
                return event.source.array[indexPath.row].record
            }
            .bind(to: self) { me, record in
                me.selectedRecord = record
                me.performSegue(withIdentifier: SegueId.record.rawValue, sender: me)
        }

        actionButton.reactive.tap
            .with(latestFrom: viewModel.isRecording()) { $1 }
            .bind(to: self) { me, isRecording in
                if isRecording {
                    me.viewModel.stop()
                } else {
                    me.viewModel.start()
                }
        }
    }    
    
}
