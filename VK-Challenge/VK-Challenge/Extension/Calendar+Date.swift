//
//  Calendar+Date.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public extension Calendar {
    public func isDateInThisYear(_ date: Date) -> Bool {
        return compare(Date(), to: date, toGranularity: .year) == .orderedSame
    }
}
