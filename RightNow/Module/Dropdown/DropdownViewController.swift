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
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        renderViewModel()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        focusOnNextReminderInputView()
    }
}


private extension DropdownViewController {
    func updatePopoverContentSize() {
        viewModel.invalidateIntrinsicContentSize()
        contentStackView.invalidateIntrinsicContentSize()
        preferredContentSize = view.bounds.size
    }
    
    func renderViewModel() {
        contentStackView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .leastNormalMagnitude) {
            // Async after a small duration to ensuare view layout.
            self.updatePopoverContentSize()
            self.focusOnNextReminderInputView()
        }
    }
    
    func focusOnNextReminderInputView() {
        viewModel.nextReminderInputView.textField?.beginEditing()
    }
    
    func customInit() {
        // Nothing.
    }
    
    func handleEnterOfNextReminderTextField(_ textField: NSTextField) {
        let reminderName = textField.stringValue
        viewModel.nextReminderInputView.viewModel.showIndicator = true
        reminderCreator.createReminder(
            named: reminderName
        ) { [unowned self, weak textField] result in
            defer {
                self.viewModel.nextReminderInputView.viewModel.showIndicator = false
            }

            guard let reminder = try? result.get() else {
                // TODO: Handle creation failure
                return
            }
            
            var lastReminder = ViewModel.createLastReminder()
            lastReminder.title = reminderName
            lastReminder.reminderID = reminder.calendarItemIdentifier
            self.viewModel.lastReminder = lastReminder
            self.viewModel.nextReminder = ViewModel.createNextReminder()
            self.renderViewModel()
        }
    }
    
    func handleEnterOfLastReminderTextField(_ textField: NSTextField) {
        let reminderName = textField.stringValue
        viewModel.lastReminderInputView.viewModel.showIndicator = true
        guard
            let lastReminder = viewModel.lastReminder,
            let id = lastReminder.reminderID
        else {
            self.viewModel.lastReminderInputView.viewModel.showIndicator = false
            return
        }
        reminderCreator.removeReminder(with: id) { [weak self, weak textField] error in
            guard let self = self else { return }
            guard error == nil else {
                switch error {
                case .reminderNotExist:
                    // TODO: Tell the user that this reminder is missing
                    self.viewModel.lastReminder = nil
                    self.viewModel.lastReminderInputView.viewModel.showIndicator = false
                    self.renderViewModel()
                default:
                    break
                }
                return
            }
            self.reminderCreator.createReminder(named: reminderName) { result in
                defer {
                    self.viewModel.lastReminderInputView.viewModel.showIndicator = false
                }
                guard let created = try? result.get() else {
                    // TODO: Failed to recreate
                    return
                }
                var newLastReminder = lastReminder
                newLastReminder.title = reminderName
                newLastReminder.reminderID = created.calendarItemIdentifier
                self.viewModel.lastReminder = newLastReminder
                self.renderViewModel()
                self.focusOnNextReminderInputView()
            }
        }
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
        if reminderInputView == viewModel.nextReminderInputView {
            handleEnterOfNextReminderTextField(textField)
        } else if reminderInputView == viewModel.lastReminderInputView {
            handleEnterOfLastReminderTextField(textField)
        } else {
            fatalError("The enter event is sent from an unknown input view.")
        }
    }
    
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldTextDidChange textField: AutoExpandingTextField
    ) {
        updatePopoverContentSize()
    }
}
