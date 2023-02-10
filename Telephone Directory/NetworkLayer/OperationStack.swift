//
//  OperationStack.swift
//  Telephone Directory
//
//  Created by Diana Princess on 08.02.2023.
//

import Foundation

class OperationStack {
    private let operationLimit: Int

    private var array: [Operation] = []
    
    init(operationLimit: Int) {
        self.operationLimit = operationLimit
    }
    
    func push(_ operation: Operation) {
        array.append(operation)
    }
    
    func exceedingLimit() -> Int {
        return (array.count - operationLimit <= 0) ? 0 : array.count - operationLimit
    }
    
    func trimOperationsIfNeeded() {
        while exceedingLimit() > 0  {
            popFirst()?.cancel()
        }
    }
    
    private func popFirst() -> Operation? {
       return array.removeFirst()
   }
}
