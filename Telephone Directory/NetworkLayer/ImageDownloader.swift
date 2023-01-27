//
//  ImageDownloader.swift
//  Telephone Directory
//
//  Created by Diana Princess on 27.01.2023.
//

import Foundation

class AsyncOperation: Operation {
    override var isAsynchronous: Bool { return true }
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    override var isFinished: Bool {
        return state == .finished
    }
    var state = OperationState.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        main()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
}

enum OperationState: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
        return "is" + rawValue.capitalized
    }
}

class ImageDownloader: AsyncOperation {
    var imageURL: String
    var result: Result<Data, HTTPError>?
    
    init(imageURLString: String) {
        self.imageURL = imageURLString
        super.init()
    }
    
    override func main() {
        loadImage(from: imageURL) { response in
            switch response {
            case .success(let data):
                guard let data = data else { return }
                self.result = .success(data)
                self.state = .finished
            case .failure(let error):
                self.result = .failure(error)
                self.state = .finished
            }
        }
    }
    
    func loadImage(from text: String, completion: @escaping(Result<Data?, HTTPError>) -> Void) {
        guard let photoUrl = URL(string: text) else { return }
        let request = URLRequest(url: photoUrl)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                completion(.failure(HTTPError.transportError(error)))
                return
            }
            do{
                let resp = response as! HTTPURLResponse
                let status = resp.statusCode
                guard (200...299).contains(status) else {
                    completion(.failure(HTTPError.httpError(status)))
                    return
                }
                let correctResponse = data!
                completion(.success(correctResponse))
            }
        }.resume()
    }
}
