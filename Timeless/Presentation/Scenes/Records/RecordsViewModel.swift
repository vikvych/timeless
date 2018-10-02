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
    
    init(with dataModelContainer: RecordsDataModelContainer) {
        self.dataModelContainer = dataModelContainer
    }
    
    func records() -> SafeSignal<ObservableArrayEvent<RecordInfo>> {
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
        return current.ignoreNil().map(recordInfo)
    }
    
    func timer() -> SafeSignal<String> {
        return current.ignoreNil()
            .flatMapLatest { record -> SafeSignal<String> in
                if record.isRecording {
                    return SafeSignal<Void>.interval(1.0).map { _ in record.durationString }
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
        guard var record = current.value else { return }
        
        record.endedAt = Date()
        
        dataModelContainer.recordsDataModel.add(record: record)
        current.value = nil
    }
    
    func duplicate(record: Record) {
        stop()
        
        let duplicate = Record(title: record.title, comment: record.comment, project: record.project)
        
        dataModelContainer.recordsDataModel.add(record: duplicate)
        current.value = duplicate
    }
    
    private func recordInfo(with record: Record) -> RecordInfo {
        return RecordInfo(record: record,
                          title: record.title ?? Strings.Records.titlePlaceholder,
                          projectName: record.project?.name ?? Strings.Records.projectPlaceholder,
                          dateString: dateString(for: record),
                          durationString: record.durationString,
                          isTitlePlaceholder: nil == record.title,
                          isProjectPlaceholder: nil == record.project?.name)
    }
    
    private func dateString(for record: Record) -> String {
        let date = dateFormatter.string(from: record.startedAt)
        let from = timeFormatter.string(from: record.startedAt)
        let till = timeFormatter.string(from: record.endedAt ?? Date())
        
        return "\(date) \(from) - \(till)"
    }
    
}
