//
//  DumbDataStore.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation
import ReactiveKit

class DumbDataStore {
    
    private var records: Property<[Record]>!
    private var projects: Property<[Project]>!
    private var appWillResignActiveObserver: AnyObject?
    
    static let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/file.json"
    
    init() {
        var info: Info? = nil
        
        do {
            info = try restore()
        } catch {
            print(error)
        }
        
        records = Property(info?.records ?? [])
        projects = Property(info?.projects ?? [])
        appWillResignActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] notification in
            do {
                try self?.save()
            } catch {
                print(error)
            }
        }
    }
    
    func save() throws {
        let info = Info(records: records.value, projects: projects.value)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(info)
        
        try data.write(to: URL(fileURLWithPath: DumbDataStore.filePath))
    }
    
    func restore() throws -> Info? {
        guard FileManager.default.fileExists(atPath: DumbDataStore.filePath) else { return nil }
        
        let decoder  = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try Data(contentsOf: URL(fileURLWithPath: DumbDataStore.filePath))
        
        return try decoder.decode(Info.self, from: data)
    }
    
    struct Info: Codable {
        let records: [Record]
        let projects: [Project]
    }
    
}

extension DumbDataStore: RecordsLocalDataSource {
    
    func records(with relations: Record.Relations) -> SafeSignal<[Record]> {
        return resolve(records: records.toSignal(), relations: relations)
    }
    
    func projects(with relations: Project.Relations) -> SafeSignal<[Project]> {
        return resolve(projects: projects.toSignal(), relations: relations)
    }
    
    func recordInfo(for id: ID, relations: Record.Relations) -> SafeSignal<Record?> {
        let filtered = records.toSignal().map { records -> [Record] in
            if let record = records.first(where: { $0.id == id }) {
                return [record]
            } else {
                return []
            }
        }
        
        return resolve(records: filtered, relations: relations).map { $0.first }
    }
    
    func projectInfo(for id: ID, relations: Project.Relations) -> SafeSignal<Project?> {
        let filtered = projects.toSignal().map { projects -> [Project] in
            if let project = projects.first(where: { $0.id == id }) {
                return [project]
            } else {
                return []
            }
        }
        
        return resolve(projects: filtered, relations: relations).map { $0.first }
    }
    
    func add(record: Record) -> SafeSignal<Void> {
        var record = record
        
        if let project = record.project {
            _ = add(project: project)
            
            record.project = nil
        }
        
        if let index = records.value.map({ $0.id }).firstIndex(of: record.id) {
            records.value.replaceSubrange(index...index, with: [record])
        } else {
            records.value.append(record)
        }
        
        return .completed()
    }
    
    func add(project: Project) -> SafeSignal<Void> {
        var project = project
        
        project.records = nil
        
        if let index = projects.value.map({ $0.id }).firstIndex(of: project.id) {
            projects.value.replaceSubrange(index...index, with: [project])
        } else {
            projects.value.append(project)
        }
        
        return SafeSignal.completed()
    }
    
    private func resolve(records: SafeSignal<[Record]>, relations: Record.Relations) -> SafeSignal<[Record]> {
        guard !relations.isEmpty else { return records }
        
        var result = records
        
        if relations.contains(.project) {
            result = combineLatest(result, projects.toSignal()) { records, projects in
                return records.map { record in
                    if let projectId = record.projectId {
                        var record = record
                        
                        record.project = projects.first { $0.id == projectId }
                        
                        return record
                    } else {
                        return record
                    }
                }
            }
        }
        
        return result
    }
    
    private func resolve(projects: SafeSignal<[Project]>, relations: Project.Relations) -> SafeSignal<[Project]> {
        guard !relations.isEmpty else { return projects }
        
        var result = projects
        
        if relations.contains(.records) {
            result = combineLatest(result, records.toSignal()) { projects, records in
                return projects.map { project in
                    var project = project
                    
                    project.records = records
                        .filter { $0.projectId == project.id }
                        .sorted { $0.startedAt < $1.startedAt }
                    
                    return project
                }
            }
        }
        
        return result
    }
    
}
