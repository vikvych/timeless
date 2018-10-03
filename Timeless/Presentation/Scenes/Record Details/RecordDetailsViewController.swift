//
//  RecordDetailsViewController.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

private let projectSuggestionsCount = 3
private let projectSuggestionsRowHeight: CGFloat = 36.0

class RecordDetailsViewController: UIViewController, FlowScene {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var projectTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var addProjectButton: UIButton!
    @IBOutlet weak var changeStartedAtButton: UIButton!
    @IBOutlet weak var submitStartedAtButton: UIButton!
    @IBOutlet weak var changeEndedAtButton: UIButton!
    @IBOutlet weak var submitEndedAtButton: UIButton!
    @IBOutlet weak var startedAtPicker: UIDatePicker!
    @IBOutlet weak var endedAtPicker: UIDatePicker!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var actionButton: ActionButton!
    @IBOutlet weak var projectSuggestionsView: UIView!
    @IBOutlet weak var projectSuggestionsTableView: UITableView!
    @IBOutlet weak var projectSuggestionsHeightConstraint: NSLayoutConstraint!
    
    weak var flowCoordinator: MainFlowCoordinator?
    
    var viewModel: RecordDetailsViewModel!
    
    private var keyboardObserver: NSObjectProtocol?
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionButton.setImageScaleToParent(1.0)
        projectSuggestionsTableView.rowHeight = projectSuggestionsRowHeight
        projectSuggestionsTableView.layer.masksToBounds = true
        projectSuggestionsTableView.layer.cornerRadius = 4.0
        projectSuggestionsView.layer.masksToBounds = false
        projectSuggestionsView.layer.cornerRadius = 4.0
        projectSuggestionsView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        projectSuggestionsView.layer.shadowColor = UIColor.black.cgColor
        projectSuggestionsView.layer.shadowOpacity = 0.2
        
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
        viewModel.selectedRecord()
            .bind(to: self) { me, record in
                me.titleTextField.text = record.title
                me.projectTextField.text = record.project?.name
                me.commentTextField.text = record.comment
                me.changeStartedAtButton.setTitle(me.dateFormatter.string(from: record.startedAt), for: .normal)
                me.startedAtPicker.date = record.startedAt
                me.startedAtPicker.maximumDate = Date()
                
                if let endedAt = record.endedAt {
                    me.changeEndedAtButton.isHidden = false
                    me.changeEndedAtButton.setTitle(me.dateFormatter.string(from: endedAt), for: .normal)
                    me.endedAtPicker.date = endedAt
                    me.endedAtPicker.minimumDate = record.startedAt.addingTimeInterval(60)
                } else {
                    me.changeEndedAtButton.isHidden = true
                }
        }
        
        viewModel.timer()
            .bind(to: self) { me, durationString in
                me.durationLabel.text = durationString
        }
        
        viewModel.isRecording()
            .bind(to: self) { me, isRecording in
                me.actionButton.isHidden = !isRecording
        }
        
        bindDatePicker(startedAtPicker, changeButton: changeStartedAtButton, submitButton: submitStartedAtButton) { me, record in
            me.viewModel.update(startedAt: me.startedAtPicker.date)
        }
        
        bindDatePicker(endedAtPicker, changeButton: changeEndedAtButton, submitButton: submitEndedAtButton) { me, record in
            me.viewModel.update(endedAt: me.endedAtPicker.date)
        }
        
        addProjectButton.reactive.tap
            .bind(to: self) { me, _ in
                if let text = me.projectTextField.text {
                    me.viewModel.addProject(with: text)
                }
        }
        
        actionButton.reactive.tap
            .bind(to: self) { me, isRecording in
                me.viewModel.stop()
        }
        
        bindProjectSuggestions()
    }
    
    private func bindDatePicker(_ datePicker: UIDatePicker, changeButton: UIButton, submitButton: UIButton, action: @escaping (RecordDetailsViewController, Record) -> Void) {
        changeButton.reactive.tap
            .bind(to: self) { me, _ in
                UIView.animate(withDuration: 0.25, animations: {
                    datePicker.isHidden = false
                    submitButton.isHidden = false
                    changeButton.isHidden = true
                    changeButton.alpha = 0.0
                }) { _ in
                    changeButton.alpha = 1.0
                }
        }
        
        submitButton.reactive.tap
            .with(latestFrom: viewModel.selectedRecord()) { _, record in record }
            .bind(to: self) { me, record in
                datePicker.isHidden = true
                submitButton.isHidden = true
                changeButton.isHidden = false
                action(me, record)
        }
    }
    
    private func bindProjectSuggestions() {
        let searchTextAndProjects = projectTextField.reactive.text
            .combineLatest(with: viewModel.projects()) { text, projects in (text: text, projects: projects) }
        
        let suggestions = searchTextAndProjects
            .with(latestFrom: viewModel.selectedRecord()) { tuple, record -> [Project] in
                if let text = tuple.text, !text.isEmpty {
                    if let currentProjectName = record.project?.name, currentProjectName == text {
                        return []
                    }
                    
                    var projects = tuple.projects.filter { $0.name.starts(with: text) }
                    
                    if projects.count > projectSuggestionsCount {
                        projects = Array(projects[..<projectSuggestionsCount])
                    }
                    
                    return projects
                } else {
                    return []
                }
        }
        
        suggestions
            .doOn(next: { [weak self] (projects: [Project]) -> Void in
                self?.projectSuggestionsHeightConstraint.constant = CGFloat(projects.count) * projectSuggestionsRowHeight
            })
            .bind(to: projectSuggestionsTableView) { projects, indexPath, tableView -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                let project = projects[indexPath.row]
                
                cell.textLabel?.text = project.name
                
                return cell
        }
        
        projectSuggestionsTableView.reactive.selectedRowIndexPath
            .with(latestFrom: suggestions) { indexPath, projects in (indexPath: indexPath, projects: projects) }
            .bind(to: self) { me, tuple in
                let project = tuple.projects[tuple.indexPath.row]
                
                me.projectTextField.reactive.text.next(project.name)
                me.viewModel.updateRecordProject(project)
        }
        
        searchTextAndProjects
            .bind(to: self) { me, tuple in
                let projectNames = tuple.projects.map { $0.name.uppercased() }
                
                if let text = tuple.text {
                    me.addProjectButton.isHidden = text.isEmpty || projectNames.contains(text.uppercased())
                } else {
                    me.addProjectButton.isHidden = true
                }
        }
    }

}

extension RecordDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let next = view.viewWithTag(textField.tag + 1) {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case titleTextField:
            viewModel.update(title: textField.text)
        case commentTextField:
            viewModel.update(comment: textField.text)
//        case projectTextField:
//            viewModel.addProject(with: <#T##String#>)
        default:
            break
        }
    }
    
}
