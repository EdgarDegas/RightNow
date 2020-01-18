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
            case current
        }
        
        struct Reminder {
            var indication: String
            var title: String
        }
        
        var lastReminder: Reminder?
        var currentReminder: Reminder = createCurrentReminder()
        
        var lastReminderCell = ReminderInputView()
        var currentReminderCell = ReminderInputView()
        
        var numberOfRows: Int {
            // If there is no last reminder, return 1:
            lastReminder != nil ? 2 : 1
        }
        
        func getRowType(at row: Int) -> Row {
            if lastReminder == nil {
                return .current
            } else {
                return Row(rawValue: row)!
            }
        }
        
        func cellForRow(_ row: Int) -> ReminderInputView {
            let rowType = getRowType(at: row)
            switch rowType {
            case .last:
                lastReminderCell.viewModel = .init(reminder: lastReminder!)
                return lastReminderCell
            case .current:
                currentReminderCell.viewModel = .init(reminder: currentReminder)
                return currentReminderCell
            }
        }
        
        init() {
            currentReminderCell.translatesAutoresizingMaskIntoConstraints = false
            lastReminderCell.translatesAutoresizingMaskIntoConstraints = false
            if let lastReminder = lastReminder {
                lastReminderCell.viewModel = .init(reminder: lastReminder)
            }
            currentReminderCell.viewModel = .init(reminder: currentReminder)
        }
    }
}


extension DropdownViewController.ViewModel {
    static func createCurrentReminder() -> Reminder {
        .init(indication: "What to do next: ", title: "")
    }
    
    static func createLastReminder() -> Reminder {
        .init(indication: "⌘⇧↑ to edit", title: "")
    }
}


private extension ReminderInputView.ViewModel {
    init(reminder: DropdownViewController.ViewModel.Reminder) {
        labelText = reminder.indication
        textFieldPlaceholder = "Brief description of the reminder..."
        textFieldText = reminder.title
    }
}
