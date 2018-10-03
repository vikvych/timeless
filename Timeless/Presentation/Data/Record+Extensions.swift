//
//  Record+Extensions.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

extension Record {
    
    var isRecording: Bool {
        return nil == endedAt
    }
    
    var displayTitle: String {
        return (title?.isEmpty ?? true) ? Strings.Records.titlePlaceholder : title!
    }
    
    var displayProjectName: String {
        return (project?.name.isEmpty ?? true) ? Strings.Records.projectPlaceholder : project!.name
    }
    
    var durationString: String {
        let timeInterval = (endedAt ?? Date()).timeIntervalSinceReferenceDate - startedAt.timeIntervalSinceReferenceDate
        
        let seconds = Int(timeInterval) % 60
        let minutes = (Int(timeInterval) / 60) % 60
        let hours = Int(timeInterval) / 3600
        
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
        
}
