//
//  OperationStack.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.02.2023.
//

import Foundation

struct OperationStack {
    private var imageDownloaderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    private var downloaderArray: [(Int, Operation)] = []
    
    mutating func push(operation: Operation, index: Int) {
        downloaderArray.append((index, operation))
        imageDownloaderQueue.addOperation(operation)
    }
    
    mutating func pop() -> (Int, Operation) {
        let tuple = downloaderArray.removeLast()
        imageDownloaderQueue.operations[tuple.0].cancel()
        return tuple
    }
    
    func count() -> Int {
        return downloaderArray.count
    }
}
