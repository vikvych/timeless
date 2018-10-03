//
//  RecordsDataModel.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation
import ReactiveKit

protocol RecordsDataModelContainer {
    
    var recordsDataModel: RecordsDataModel { get }
    
}

protocol RecordsRemoteDataSource {
    //    TODO: implement API dependend methods
}

protocol RecordsLocalDataSource {
    
    func records(with relations: Record.Relations) -> SafeSignal<[Record]>
    func projects(with relations: Project.Relations) -> SafeSignal<[Project]>
    func recordInfo(for id: ID, relations: Record.Relations) -> SafeSignal<Record?>
    func projectInfo(for id: ID, relations: Project.Relations) -> SafeSignal<Project?>
    func add(record: Record)
    func add(project: Project)
    func generateSampleData()
    
}

struct RecordsDataModel {
    
    private let remoteDataSource: RecordsRemoteDataSource
    private let localDataSource: RecordsLocalDataSource
    
    init(remoteDataSource: RecordsRemoteDataSource, localDataSource: RecordsLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func records() -> SafeSignal<[Record]> {
        return localDataSource.records(with: [.project])
    }
    
    func projects(withDetails: Bool = false) -> SafeSignal<[Project]> {
        return localDataSource.projects(with: withDetails ? [.records] : [])
    }
    
    func add(record: Record) {
        localDataSource.add(record: record)
    }
    
    func add(project: Project) {
        localDataSource.add(project: project)
    }
    
    func generateSampleData() {
        localDataSource.generateSampleData()
    }
    
}
