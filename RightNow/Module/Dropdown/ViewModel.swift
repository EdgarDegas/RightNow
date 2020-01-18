//
//  ViewModel.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

extension DropdownViewController {
    struct ViewModel {
        enum Row: Int {
            case last
            case next
        }
        
        struct Reminder {
            var indication: String
            var title: String
            var reminderID: String?
        }
        
        var lastReminder: Reminder?
        var nextReminder: Reminder = createNextReminder()
        
        var lastReminderInputView = ReminderInputView()
        var nextReminderInputView = ReminderInputView()
        
        var numberOfRows: Int {
            // If there is no last reminder, return 1:
            lastReminder != nil ? 2 : 1
        }
        
        func invalidateIntrinsicContentSize() {
            nextReminderInputView.textField.invalidateIntrinsicContentSize()
            nextReminderInputView.contentStackView.invalidateIntrinsicContentSize()
            lastReminderInputView.textField.invalidateIntrinsicContentSize()
            lastReminderInputView.contentStackView.invalidateIntrinsicContentSize()
        }
        
        func getRowType(at row: Int) -> Row {
            if lastReminder == nil {
                return .next
            } else {
                return Row(rawValue: row)!
            }
        }
        
        func cellForRow(_ row: Int) -> ReminderInputView {
            let rowType = getRowType(at: row)
            switch rowType {
            case .last:
                lastReminderInputView.viewModel = .init(reminder: lastReminder!)
                return lastReminderInputView
            case .next:
                nextReminderInputView.viewModel = .init(reminder: nextReminder)
                return nextReminderInputView
            }
        }
        
        init() {
            nextReminderInputView.translatesAutoresizingMaskIntoConstraints = false
            lastReminderInputView.translatesAutoresizingMaskIntoConstraints = false
            if let lastReminder = lastReminder {
                lastReminderInputView.viewModel = .init(reminder: lastReminder)
            }
            nextReminderInputView.viewModel = .init(reminder: nextReminder)
        }
    }
}


extension DropdownViewController.ViewModel {
    static func createNextReminder() -> Reminder {
        .init(indication: "􀈎 What to do next: ", title: "")
    }
    
    static func createLastReminder() -> Reminder {
        .init(indication: "􀂎 Successfully added reminder (⌘⇧↑ to edit):", title: "")
    }
}


private extension ReminderInputView.ViewModel {
    init(reminder: DropdownViewController.ViewModel.Reminder) {
        labelText = reminder.indication
        textFieldPlaceholder = "Brief description of the reminder..."
        textFieldText = reminder.title
    }
}
