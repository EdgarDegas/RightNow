//
//  Set+Extensions.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Foundation

extension Set where Element == Calendar.Component {
    static var yearToDay: Self {
        [.year, .month, .day]
    }
    
    static var yearToSecond: Self {
        [.year, .month, .day, .hour, .minute, .second]
    }
}
