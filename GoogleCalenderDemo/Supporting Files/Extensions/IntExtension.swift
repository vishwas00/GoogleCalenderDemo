//
//  IntExtension.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 05/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var boolValue: Bool? {
        switch self {
        case 1:
            return true
        case 0:
            return false
        default:
            return nil
        }
    }
}
