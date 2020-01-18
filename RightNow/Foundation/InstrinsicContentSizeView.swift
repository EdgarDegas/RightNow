//
//  InstrinsicContentSizeView.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

class InstrinsicContentSizeView: NSView {
    override var intrinsicContentSize: NSSize {
        bounds.size
    }
}
