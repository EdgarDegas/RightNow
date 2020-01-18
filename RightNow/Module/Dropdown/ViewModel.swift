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
            var title: String
        }
        
        var lastReminder: Reminder?
        var currentReminder: Reminder = .init(title: "")
        
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
                return lastReminderCell
            case .current:
                return currentReminderCell
            }
        }
        
        init() {
            currentReminderCell.translatesAutoresizingMaskIntoConstraints = false
            lastReminderCell.translatesAutoresizingMaskIntoConstraints = false
            if let lastReminder = lastReminder {
                lastReminderCell.textField?.stringValue = lastReminder.title
            }
            currentReminderCell.textField?.stringValue = currentReminder.title
        }
    }
}
