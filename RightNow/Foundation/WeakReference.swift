//
//  WeakReference.swift
//  RightNow
//
//  Created by iMoe on 2020/1/18.
//  Copyright © 2020 imoe. All rights reserved.
//

import Foundation

struct WeakReference<Object: AnyObject> {
    weak var wrappedObject: Object?
    
    init(to wrappedObject: Object?) {
        self.wrappedObject = wrappedObject
    }
}

extension WeakReference: Equatable where Object: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedObject == rhs.wrappedObject
    }
}

extension WeakReference: Hashable where Object: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedObject)
    }
}
