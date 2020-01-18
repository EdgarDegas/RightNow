//
//  ReminderCreator.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import EventKit

final class ReminderCreator {
    
    private(set) var accessRequested: Bool = false
    
    private let eventStore = EKEventStore()
    
    enum Error: Swift.Error {
        case underlying(error: Swift.Error)
    }
    
    typealias ReminderCreationResult = Result<EKReminder, Error>
    typealias ReminderCreationCompletion = ((ReminderCreationResult) -> Void)
    
    init() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            accessRequested = true
        default:
            break
        }
    }
    
    /// Create a reminder with the given name.
    /// 
    /// The completion is guaranteed to be invoked on the main queue.
    func createReminder(named name: String, completion: ReminderCreationCompletion? = nil) {
        guard name.isEmpty == false else { return }
        let creation: (String) -> Void = { [weak self] text in
            guard let self = self else { return }
            self.performCreationOfReminder(named: text) { result in
                completion?(result)
            }
        }
        
        guard accessRequested else {
            eventStore.requestAccess(to: .reminder) { [weak self] succeeded, error in
                guard let self = self else { return }
                self.accessRequested = true
                DispatchQueue.main.async {
                    creation(name)
                }
            }
            return
        }
        
        creation(name)
    }
}


private extension ReminderCreator {
    func performCreationOfReminder(
        named name: String,
        completion: @escaping ReminderCreationCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = name
            let calendar = self.eventStore.defaultCalendarForNewReminders()
            reminder.calendar = calendar
            reminder.dueDateComponents = Calendar.current.dateComponents(.yearToDay, from: .init())
            do {
                try self.eventStore.save(reminder, commit: true)
                DispatchQueue.main.async {
                    completion(.success(reminder))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.underlying(error: error)))
                }
            }
        }
    }
}
