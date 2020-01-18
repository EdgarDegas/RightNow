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
    
    var viewModel = ViewModel()
    
    private var accessRequested: Bool = false
    
    @IBOutlet weak var contentStackView: StackView!
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private lazy var eventStore: EKEventStore = {
        .init()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        renderViewModel()
    }
}

private extension DropdownViewController {
    func updatePopoverContentSize() {
        preferredContentSize = view.bounds.size
    }
    
    func renderViewModel() {
        contentStackView.reloadData()
        updatePopoverContentSize()
    }
    
    func creatingEvent(named name: String, completion: (() -> Void)? = nil) {
        defer {
            completion?()
        }
        guard name.isEmpty == false else { return }
        let creation: (String) -> Void = { [weak self] text in
            guard let self = self else { return }
            self.performCreationOfEvent(named: text) {
                self.viewModel.lastReminder = .init(title: text)
                self.viewModel.currentReminder = .init(title: "")
                self.renderViewModel()
            }
        }
        
        guard accessRequested else {
            eventStore.requestAccess(to: .reminder) { [weak self] succeeded, error in
                guard let self = self else { return }
                self.accessRequested = true
                print("wts")
                DispatchQueue.main.async {
                    creation(name)
                }
            }
            return
        }
        
        creation(name)
    }
    
    func customInit() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            accessRequested = true
        default:
            break
        }
    }
    
    func performCreationOfEvent(named name: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = name
            let calendar = self.eventStore.defaultCalendarForNewReminders()
            reminder.calendar = calendar
            reminder.dueDateComponents = Calendar.current.dateComponents(.yearToDay, from: .init())
            //            try? self.eventStore.save(reminder, commit: true)
            DispatchQueue.main.async {
                completion?()
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
        textField.isEnabled = false
        creatingEvent(named: textField.stringValue) { [weak textField] in
            textField?.isEnabled = true
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


private extension Set where Element == Calendar.Component {
    static var yearToDay: Self {
        [.year, .month, .day]
    }
    
    static var yearToSecond: Self {
        [.year, .month, .day, .hour, .minute, .second]
    }
}
