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

}
