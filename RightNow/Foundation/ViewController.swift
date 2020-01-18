//
//  ViewController.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

class ViewController:
    NSViewController,
    AppearanceUpdateSubscriberProtocol
{
    var appearanceUpdateSubscription: Subscription?
    
    func respondToAppearanceUpdate(into appearanceName: NSAppearance.Name) {
        // Do nothing.
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInitialize()
    }
    
    /// This method is invoked inside any initializer, after calling `super`.
    func customInitialize() { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToAppearanceUpdate()
    }
}
