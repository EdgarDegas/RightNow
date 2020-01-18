//
//  AppDelegate.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let popover = NSPopover()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        popover.behavior = .transient
        popover.appearance = NSAppearance.current
        
        let button = statusItem.button
        button?.action = #selector(togglePopover(_:))
        button?.title = "Right Now"
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        //2.
        let identifier = "View Controller"
        //3.
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? DropdownViewController else {
            fatalError("Storyboard ID not set.")
        }
        popover.contentViewController = viewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.contentSize = popover.contentViewController!.view.bounds.size
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
}

