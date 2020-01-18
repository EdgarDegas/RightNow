//
//  AutoExpandingTextField.swift
//  RightNow
//
//  Created by iMoe on 2020/1/17.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

class AutoExpandingTextField: NSTextField {
    override var intrinsicContentSize: NSSize {
        let font = self.font!
        let advancement = font.advancement(forGlyph: font.glyph(withName: "x")).width
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let boundingRect = stringValue.boundingRect(
            with: .init(width: bounds.width - advancement, height: .infinity),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle
        ])
        return boundingRect.size
    }
}
