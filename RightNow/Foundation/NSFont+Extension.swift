//
//  NSFont+Extension.swift
//  RightNow
//
//  Created by iMoe on 2020/1/17.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

extension NSFont {
    var lineHeight: CGFloat {
        leading + descender + ascender
    }
}
