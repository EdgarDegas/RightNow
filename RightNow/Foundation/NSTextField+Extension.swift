//
//  NSTextField+Extension.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

extension NSTextField {
    /// Become first responder.
    func beginEditing(selectingAllText: Bool = false) {
        window?.makeFirstResponder(self)
        if selectingAllText == false {
            let length = stringValue.count
            currentEditor()?.selectedRange = .init(location: length, length: 0)
        }
    }
    
    var isFirstResponder: Bool {
        window?.firstResponder == currentEditor()
    }
}
