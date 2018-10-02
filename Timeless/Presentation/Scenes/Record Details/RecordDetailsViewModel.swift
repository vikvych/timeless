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

    func recordInfo() -> SafeSignal<Record> {
        return record.toSignal()
    }
    
    func timer() -> SafeSignal<String> {
        return record.flatMapLatest { record -> SafeSignal<String> in
            if record.isRecording {
                return SafeSignal<Void>.interval(1.0).map { _ in record.durationString }
            } else {
                return SafeSignal.just(record.durationString)
            }
        }
    }
    
    func update(record: Record) {
        
    }

}
