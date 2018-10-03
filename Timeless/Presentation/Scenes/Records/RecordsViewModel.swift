//
//  RecordsViewModel.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond

struct RecordInfo {
    let record: Record
    let title: String
    let projectName: String
    let dateString: String
    let durationString: String
    let isTitlePlaceholder: Bool
    let isProjectPlaceholder: Bool
}

struct RecordsViewModel {
    
    private let dataModelContainer: RecordsDataModelContainer
    private let current: Property<Record?> = Property(nil)
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = .none
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    var currentRecordInstance: Record? {
        return current.value
    }
    
    init(with dataModelContainer: RecordsDataModelContainer) {
        self.dataModelContainer = dataModelContainer
    }
    
    func recordsInfo() -> SafeSignal<ObservableArrayEvent<RecordInfo>> {
        return dataModelContainer.recordsDataModel.records()
            .map { records in records.filter { nil != $0.endedAt } }
            .diff()
            .lazyMap(recordInfo)
    }
    
    func isRecording() -> SafeSignal<Bool> {
        return current.map { $0?.isRecording ?? false }
    }

    func isCurrentRecordHidden() -> SafeSignal<Bool> {
        return current.map { $0 == nil }.distinct()
    }

    func currentRecord() -> SafeSignal<RecordInfo> {
        let updates = dataModelContainer.recordsDataModel.records()
            .with(latestFrom: current.toSignal()) { records, current -> Void in
                guard let current = current else { return }
                
                let recordsIds = records.map { $0.id }
                
                if let index = recordsIds.index(of: current.id) {
                    let updated = records[index]
                    
                    if updated != current {
                        if updated.isRecording {
                            self.current.value = updated
                        } else {
                            self.current.value = nil
                        }
                    }
                } else {
                    self.current.value = nil
                }
        }
        
        return current.ignoreNil()
            .combineLatest(with: updates) { record, _ in record }
            .map(recordInfo)
    }
    
    func timer() -> SafeSignal<String> {
        return current.ignoreNil()
            .flatMapLatest { record -> SafeSignal<String> in
                if record.isRecording {
                    return SafeSignal<Void>.interval(1.0)
                        .map { _ in record.durationString }
                        .start(with: record.durationString)
                } else {
                    return SafeSignal.just(record.durationString)
                }
            }
    }
    
    func start() {
        guard nil == current.value else { return }
        
        let record = Record()
        
        dataModelContainer.recordsDataModel.add(record: record)
        current.value = record
    }
    
    func stop() {
        guard var record = current.value, record.isRecording else { return }
        
        record.endedAt = Date()
        
        dataModelContainer.recordsDataModel.add(record: record)
        current.value = nil
    }
    
    func createNew(from duplicate: Record? = nil) -> Record {
        stop()
        
        let record = Record()
        
        dataModelContainer.recordsDataModel.add(record: record)
        current.value = record
        
        return record
    }
    
    private func recordInfo(with record: Record) -> RecordInfo {
        let date = dateFormatter.string(from: record.startedAt)
        let from = timeFormatter.string(from: record.startedAt)
        let till = timeFormatter.string(from: record.endedAt ?? Date())
        let dateString = "\(date) \(from) - \(till)"

        return RecordInfo(record: record,
                          title: record.displayTitle,
                          projectName: record.displayProjectName,
                          dateString: dateString,
                          durationString: record.durationString,
                          isTitlePlaceholder: nil == record.title,
                          isProjectPlaceholder: nil == record.project?.name)
    }
    
}
