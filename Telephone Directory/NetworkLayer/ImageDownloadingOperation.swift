//
//  ImageDownloadingOperation.swift
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
    private var state = OperationState.ready {
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
        state = .executing
        main()
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
    
    fileprivate func finish() {
        cancel()
    }
}

enum OperationState: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
        return "is" + rawValue.capitalized
    }
}

class ImageDownloadingOperation: AsyncOperation {
    private var imageURL: String
    private var resultHandler: ((ImageDownloadingResult) -> Void)?
    
    init(imageURLString: String, completion: @escaping(ImageDownloadingResult) -> Void) {
        self.imageURL = imageURLString
        resultHandler = completion
        super.init()
    }
    
    override func finish() {
        super.finish()
        resultHandler = nil
    }
    
    override func main() {
        guard !isCancelled else { return }
        loadImage(from: imageURL) { [ weak self ] response in
            guard let self, !self.isCancelled else { return }
            switch response {
            case .success(let data):
                self.resultHandler?(.success(data))
            case .failure(let error):
                self.resultHandler?(.failure(error))
            case .isCancelled:
                self.resultHandler?(.isCancelled)
            }
            self.finish()
        }
    }
    
    private func loadImage(from text: String, completion: @escaping(ImageDownloadingResult) -> Void) {
        guard let photoUrl = URL(string: text) else { return }
        let request = URLRequest(url: photoUrl)
        URLSession.shared.dataTask(with: request){ data, response, error in
            guard !self.isCancelled else {
                completion(.isCancelled)
                return
            }
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

enum ImageDownloadingResult {
    case isCancelled
    case success(Data?)
    case failure(HTTPError)
}
