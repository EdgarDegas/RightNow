//
//  AppearanceUpdateSubscriberProtocol.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa
import Combine

protocol AppearanceUpdateSubscriberProtocol: AnyObject {
    var appearanceUpdateSubscription: Subscription? { get set }
    
    func subscribeToAppearanceUpdate()
    
    func respondToAppearanceUpdate(into appearanceName: NSAppearance.Name)
}

extension AppearanceUpdateSubscriberProtocol {
    func subscribeToAppearanceUpdate() {
        appearanceUpdateSubscription
            = NSAppDelegate.appearanceUpdatePublisher.sink(receiveCompletion: { _ in
                // Do nothing with completion.
            }, receiveValue: { [weak self] newName in
                self?.respondToAppearanceUpdate(into: newName)
            })
    }
}
