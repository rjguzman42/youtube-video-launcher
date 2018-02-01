//
//  ShareItem.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/3/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import Foundation

struct ShareItem {
    enum ShareCategory {
        case external
        
        
        func toString() -> String {
            switch self {
            case .external:
                return "External"
            }
        }
    }
    let category: ShareCategory
    let title: String?
    let imagePath: String?
}
