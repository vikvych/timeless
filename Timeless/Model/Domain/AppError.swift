//
//  AppError.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/1/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import Foundation

enum AppError: Error {
    
    case api(error: ApiError)
    case generic(error: Error)
    
}
