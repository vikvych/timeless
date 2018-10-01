//
//  DependencyContainer.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

struct DependencyContainer: RecordsDataModelContainer {
    
    let recordsDataModel: RecordsDataModel
    
}

extension DependencyContainer {
    
    static func createDefault() -> DependencyContainer {
        let apiService = ApiService()
        let dataStore = DumbDataStore()
        
        return DependencyContainer(
            recordsDataModel: RecordsDataModel(remoteDataSource: apiService, localDataSource: dataStore)
        )
    }
    
}
