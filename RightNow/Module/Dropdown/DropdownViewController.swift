//
//  DropdownViewController.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa
import EventKit

final class DropdownViewController: NSViewController {
    
    private let reminderCreator = ReminderCreator()
    
    var viewModel = ViewModel()
    
    @IBOutlet var settingMenu: NSMenu!
    
    @IBOutlet weak var contentStackView: StackView!
    
    @IBAction func settingButtonTapped(_ sender: NSButton) {
        var anchor = sender.bounds.origin
        anchor.x += 20
        anchor.y += sender.bounds.height - 8
        settingMenu.popUp(positioning: nil, at: anchor, in: sender)
    }
    
    @IBAction func quitItemSelected(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        renderViewModel()
    }
}

private extension DropdownViewController {
    func updatePopoverContentSize() {
        NSApp.popover.contentSize = view.bounds.size
    }
    
    func renderViewModel() {
        contentStackView.reloadData()
        updatePopoverContentSize()
    }
    
    func customInit() {
        // Nothing.
    }
}

extension DropdownViewController: StackViewDataSource {
    func numberOfArrangedSubviews(in stackView: StackView) -> Int {
        viewModel.numberOfRows
    }
    
    func arrangedSubview(at row: Int, in stackView: StackView) -> NSView {
        let inputCell = viewModel.cellForRow(row)
        inputCell.delegate = self
        return inputCell
    }
}

extension DropdownViewController: ReminderInputViewDelegate {
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldDidEnter textField: AutoExpandingTextField
    ) {
        textField.isEnabled = false
        reminderCreator.createReminder(
            named: textField.stringValue
        ) { [unowned self, weak textField] in
            textField?.isEnabled = true
            self.viewModel.lastReminder = ViewModel.createLastReminder()
            self.viewModel.currentReminder = ViewModel.createCurrentReminder()
            self.renderViewModel()
        }
    }
    
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldTextDidChange textField: AutoExpandingTextField
    ) {
        contentStackView.invalidateIntrinsicContentSize()
        updatePopoverContentSize()
    }
}
