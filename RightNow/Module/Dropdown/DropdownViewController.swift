//
//  DropdownViewController.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa
import EventKit

final class DropdownViewController: ViewController {
    
    /// Tell if the reminder just created is the first one since app was launched.
    private var createdFirstReminder: Bool = false
    
    private let reminderCreator = ReminderCreator()
    
    private let uiHelper = DropdownUIHelper()
    
    var viewModel = ViewModel()
    
    @IBOutlet var settingMenu: NSMenu!
    
    @IBOutlet weak var contentStackView: StackView!
    
    @IBAction func settingButtonTapped(_ sender: NSButton) {
        uiHelper.settingButtonTapped(sender, associatedMenu: settingMenu)
    }
    
    @IBAction func quitItemSelected(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderViewModel()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        focusOnNextReminderInputView()
    }
    
    override func respondToAppearanceUpdate(into appearanceName: NSAppearance.Name) {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    }
}


private extension DropdownViewController {
    
    func isReminderNameValid(_ reminderName: String) -> Bool {
        guard
            reminderName.isEmpty == false,
            reminderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        else {
            return false
        }
        return true
    }
    
    func updatePopoverContentSize(fadeInNextReminder: Bool = false) {
        viewModel.invalidateIntrinsicContentSize()
        contentStackView.invalidateIntrinsicContentSize()
        
        if fadeInNextReminder {
            uiHelper.animateAppearingOfNextReminderView(viewModel.nextReminderInputView)
        }
    }
    
    func renderViewModel() {
        contentStackView.reloadData()
        let flag = createdFirstReminder
        createdFirstReminder = false
        self.updatePopoverContentSize(fadeInNextReminder: flag)
        DispatchQueue.main.asyncAfter(deadline: .now() + .leastNormalMagnitude) {
            // Async after a small duration to ensuare view layout.
            self.updatePopoverContentSize()
            self.focusOnNextReminderInputView()
        }
    }
    
    func focusOnNextReminderInputView() {
        viewModel.nextReminderInputView.textField?.beginEditing()
    }
    
    func handleEnterOfNextReminderTextField(_ textField: NSTextField) {
        let reminderName = textField.stringValue
        guard isReminderNameValid(reminderName) else { return }
        viewModel.nextReminderInputView.viewModel.showIndicator = true
        if viewModel.lastReminder == nil {
            createdFirstReminder = true
        }
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
        guard isReminderNameValid(reminderName) else { return }
        viewModel.lastReminderInputView.viewModel.showIndicator = true
        guard
            let lastReminder = viewModel.lastReminder,
            let id = lastReminder.reminderID
        else {
            // TODO: Tell the user that an internal error happened
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
