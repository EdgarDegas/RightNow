//
//  AppDelegate.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa
import Combine

var NSAppDelegate: AppDelegate {
    NSApp.delegate as! AppDelegate
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var appearanceUpdateSubscription: Subscription?
    
    let appearanceUpdatePublisher = CurrentValueSubject<NSAppearance.Name, Error>(NSAppearance.current.name)
    
    private var observationToken: NSKeyValueObservation!
    
    @IBAction func navigateToLastReminderSelected(_ sender: NSMenuItem) {
        dropdownViewController.viewModel.lastReminderInputView.textField.beginEditing()
    }
    
    @IBAction func navigateToNextReminderSelected(_ sender: NSMenuItem) {
        dropdownViewController.viewModel.nextReminderInputView.textField.beginEditing()
    }
    
    let popover = NSPopover()
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    weak var dropdownViewController: DropdownViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        observationToken = NSApp.observe(\.effectiveAppearance) { [unowned self] _, _ in
            NSAppearance.current = NSApp.effectiveAppearance
            self.appearanceUpdatePublisher.send(NSAppearance.current.name)
        }
        
        subscribeToAppearanceUpdate()
        popover.behavior = .transient
        
        let button = statusItem.button
        button?.action = #selector(togglePopover(_:))
        button?.title = "Right Now"
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = "View Controller"
        guard let dropdownViewController = storyboard.instantiateController(withIdentifier: identifier) as? DropdownViewController else {
            fatalError("Storyboard ID not set.")
        }
        popover.contentViewController = dropdownViewController
        self.dropdownViewController = dropdownViewController
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

extension AppDelegate: AppearanceUpdateSubscriberProtocol {
    func respondToAppearanceUpdate(into appearanceName: NSAppearance.Name) {
        popover.appearance = NSAppearance.current
    }
}
