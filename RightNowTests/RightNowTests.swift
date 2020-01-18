//
//  RightNowTests.swift
//  RightNowTests
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import XCTest
import EventKit
@testable import RightNow

class RightNowTests: XCTestCase {
    
    let reminderCreator = ReminderCreator()
    let eventStore = EKEventStore()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReminderCreation() {
        let name = UUID().uuidString
        let predicate = eventStore.predicateForReminders(in: nil)
        
        let testExpectation = XCTestExpectation()
        reminderCreator.createReminder(named: name) {
            self.eventStore.fetchReminders(matching: predicate) { reminders in
                let reminder = reminders?.first { $0.title == name }
                XCTAssertTrue(reminder != nil)
                try? self.eventStore.remove(reminder!, commit: true)
                testExpectation.fulfill()
            }
        }
        
        wait(for: [testExpectation], timeout: 10)
    }
}
