//
//  OperationStack.swift
//  Telephone Directory
//
//  Created by Diana Princess on 08.02.2023.
//

import Foundation

struct OperationStack {
    private var array: [Operation] = []
    
    mutating func push(_ operation: Operation) {
        array.append(operation)
    }
    
    mutating func popFirst() -> Operation? {
        return array.removeFirst()
    }
    
    mutating func popLast() -> Operation? {
        return array.removeLast()
    }
    
    func count() -> Int {
        return array.count
    }
}
