//
//  RecordDetailsViewController.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

class RecordDetailsViewController: UIViewController, FlowScene {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var addProjectButton: UIButton!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var changeStartedAtButton: UIButton!
    @IBOutlet weak var changeEndedAtButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startedAtPicker: UIDatePicker!
    @IBOutlet weak var endedAtPicker: UIDatePicker!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var actionButton: ActionButton!
    
    weak var flowCoordinator: MainFlowCoordinator?
    
    var viewModel: RecordDetailsViewModel!
    
    private var keyboardObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionButton.setImageScaleToParent(1.0)
        
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupObserving()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        invalidateObserving()
    }
    
    @IBAction func unwindToRecordDetails(_ segue: UIStoryboardSegue) {}
    
    private func setupObserving() {
        keyboardObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            guard
                let me = self,
                let userInfo = notification.userInfo,
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
                let animation = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
                else { return }
            
            let offset = UIScreen.main.bounds.height - keyboardFrame.minY
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: offset, right: 0.0)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.init(rawValue: animation)], animations: {
                me.scrollView.contentInset = insets
            }, completion: nil)
        }
    }
    
    private func invalidateObserving() {
        if let observer = keyboardObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardObserver = nil
        }
    }
    
    private func bindUI() {
        viewModel.recordInfo()
            .bind(to: self) { me, record in
                
        }
        
        viewModel.timer()
            .bind(to: self) { me, durationString in
                me.durationLabel.text = durationString
        }
        
        viewModel.isRecording()
            .bind(to: self) { me, isRecording in
                me.actionButton.isSelected = isRecording
        }
    }

}
