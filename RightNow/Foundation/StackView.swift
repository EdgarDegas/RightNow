//
//  StackView.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

/// Similiar to UITableViewDataSource, but for StackView.
@objc protocol StackViewDataSource: AnyObject {
    func numberOfArrangedSubviews(in stackView: StackView) -> Int
    
    func arrangedSubview(at row: Int, in stackView: StackView) -> NSView
}

class StackView: NSStackView {
    
    private var viewsWithCustomSpacing: Set<WeakReference<NSView>> = .init([])
    
    override func setCustomSpacing(_ spacing: CGFloat, after view: NSView) {
        super.setCustomSpacing(spacing, after: view)
        viewsWithCustomSpacing.insert(.init(to: view))
    }
    
    override func customSpacing(after view: NSView) -> CGFloat {
        if viewsWithCustomSpacing.contains(.init(to: view)) {
            return super.customSpacing(after: view)
        } else if view == arrangedSubviews.last {
            return 0
        } else {
            return spacing
        }
    }
    
    @IBOutlet weak var dataSource: StackViewDataSource?
    
    override var intrinsicContentSize: NSSize {
        let superIntrinsicContentSize = super.intrinsicContentSize
        let intrinsicLength = instrinsicLengthAgaintOrientation
        switch orientation {
        case .horizontal:
            return .init(
                width: intrinsicLength,
                height: max(0, superIntrinsicContentSize.height))
        case .vertical:
            return .init(
                width: max(0, superIntrinsicContentSize.width),
                height: intrinsicLength)
        default:
            return superIntrinsicContentSize
        }
    }
    
    func reloadData() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let arrangedSubviewCount = dataSource!.numberOfArrangedSubviews(in: self)
        for index in 0..<arrangedSubviewCount {
            let toInsert = dataSource!.arrangedSubview(at: index, in: self)
            addArrangedSubview(toInsert)
        }
    }
    
    var instrinsicLengthAgaintOrientation: CGFloat {
        let spacing = arrangedSubviews.reduce(0, { customSpacing(after: $1) + $0 })
        switch orientation {
        case .horizontal:
            return arrangedSubviews.reduce(0, { $0 + $1.intrinsicContentSize.width }) + spacing
        case .vertical:
            return arrangedSubviews.reduce(0, { $0 + $1.intrinsicContentSize.height }) + spacing
        default:
            return spacing
        }
    }
    
    override func addArrangedSubview(_ view: NSView) {
        super.addArrangedSubview(view)
        addEqualConstraintAgainstOrientation(to: view)
    }
}

private extension StackView {
    func addEqualConstraintAgainstOrientation(to view: NSView) {
        let attribute: NSLayoutConstraint.Attribute
        switch orientation {
        case .horizontal:
            attribute = .height
        case .vertical:
            attribute = .width
        @unknown default:
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: self,
            attribute: attribute,
            multiplier: 1,
            constant: 0)
        addConstraint(constraint)
    }
}
