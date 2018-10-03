//
//  RecordDetailsViewModel.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation
import ReactiveKit

struct RecordDetailsViewModel {
    
    private let dataModelContainer: RecordsDataModelContainer
    private let record: Property<Record>
    
    init(dataModelContainer: RecordsDataModelContainer, record: Record) {
        self.dataModelContainer = dataModelContainer
        self.record = Property(record)
    }
    
    func isRecording() -> SafeSignal<Bool> {
        return record.map { nil != $0 && nil == $0?.endedAt }
    }

    func selectedRecord() -> SafeSignal<Record> {
        return record.toSignal()
    }
    
    func projects() -> SafeSignal<[Project]> {
        return dataModelContainer.recordsDataModel.projects()
    }
    
    func timer() -> SafeSignal<String> {
        return record.flatMapLatest { record -> SafeSignal<String> in
            if record.isRecording {
                return SafeSignal<Void>.interval(1.0)
                    .map { _ in record.durationString }
                    .start(with: record.durationString)
            } else {
                return SafeSignal.just(record.durationString)
            }
        }
    }
    
    func update(startedAt: Date? = nil, endedAt: Date? = nil, title: String? = nil, comment: String? = nil) {
        var endedAt = endedAt
        
        if let startedAt = startedAt, let currentEndedAt = record.value.endedAt, currentEndedAt < startedAt {
            endedAt = startedAt.addingTimeInterval(60)
        }
        
        let value = record.value.copy(startedAt: startedAt, endedAt: endedAt, title: title, comment: comment)
        
        record.value = value
        dataModelContainer.recordsDataModel.add(record: value)
    }
    
    func updateRecordProject(_ project: Project) {
        var record = self.record.value
        
        record.project = project
        record.projectId = project.id
        
        dataModelContainer.recordsDataModel.add(record: record)
        
        self.record.value = record
    }
    
    func addProject(with name: String) {
        let project = Project(name: name)
        
        updateRecordProject(project)
    }
    
    func stop() {
        var value = record.value
        
        guard value.isRecording else { return }
        
        value.endedAt = Date()
        dataModelContainer.recordsDataModel.add(record: value)
        record.value = value
    }


}
