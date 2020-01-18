//
//  NSView+Extension.swift
//  RightNow
//
//  Created by iMoe on 2020/1/17.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

extension NSView {
    func addSubview(_ view: NSView, insets: NSEdgeInsets) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: insets.left)
        let trailingConstraint = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: insets.right)
        let topConstraint = NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: insets.top)
        let bottomConstraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: insets.bottom)
        addConstraints([
            leadingConstraint,
            trailingConstraint,
            topConstraint,
            bottomConstraint
        ])
    }
}
