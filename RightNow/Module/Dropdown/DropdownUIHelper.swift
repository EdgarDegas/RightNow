//
//  DropdownAnimator.swift
//  RightNow
//
//  Created by iMoe on 2020/1/25.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

final class DropdownUIHelper {
    func settingButtonTapped(_ settingButton: NSButton, associatedMenu: NSMenu) {
        var anchor = settingButton.bounds.origin
        anchor.x += 20
        anchor.y += settingButton.bounds.height - 8
        associatedMenu.popUp(positioning: nil, at: anchor, in: settingButton)
    }
    
    /// If the user created a reminder the first time since app was launched, call this
    /// method to animate the appearing of the next reminder input view.
    func animateAppearingOfNextReminderView(_ nextReminderInputView: ReminderInputView) {
        let endPosition = nextReminderInputView.layer!.position
        nextReminderInputView.layer?.position.y += 60
        let positionAnimation = CASpringAnimation(keyPath: #keyPath(CALayer.position))
        positionAnimation.toValue = endPosition
        positionAnimation.damping = 10
        positionAnimation.stiffness = 100
        positionAnimation.duration = positionAnimation.settlingDuration
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.fillMode = .forwards
        nextReminderInputView.layer?.add(positionAnimation, forKey: nil)
        
        nextReminderInputView.layer?.opacity = 0
        let alphaAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnimation.toValue = Float(1)
        alphaAnimation.beginTime = CACurrentMediaTime() + positionAnimation.settlingDuration / 4
        alphaAnimation.duration = 0.3
        alphaAnimation.timingFunction = .init(name: .easeOut)
        alphaAnimation.isRemovedOnCompletion = false
        alphaAnimation.fillMode = .forwards
        nextReminderInputView.layer?.add(alphaAnimation, forKey: nil)
    }
}
