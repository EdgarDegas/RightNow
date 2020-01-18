//
//  NSApplication+Extension.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

extension NSApplication {
    var popover: NSPopover {
        (delegate as! AppDelegate).popover
    }
}
