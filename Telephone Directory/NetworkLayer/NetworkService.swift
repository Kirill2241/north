//
//  NetworkService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class NetworkService {
    private var imageDownloaderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 20
        return queue
    }()
    private var operationStack = OperationStack()
    private var imageDataCache: ImageDataCacheTypeProtocol
    init(imageDataCache: ImageDataCacheTypeProtocol) {
        self.imageDataCache = imageDataCache
    }
    
    private func loadContactList(number: Int, completion: @escaping(Result<[OneContactNetworkResponse], Error>) -> Void) {
        let urlString = "https://randomuser.me/api/?results=\(number)&inc=name,phone,cell,email,nat,picture"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
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
                let correctResponse: ContactsNetworkResponse? = try? JSONDecoder().decode(ContactsNetworkResponse.self, from: data!)
                guard let array = correctResponse?.results else {
                    completion(.failure(HTTPError.httpError(0)))
                    return
                }
                completion(.success(array))
            }
        }.resume()
    }
    
    private func createNewContactItem(contact: OneContactNetworkResponse) -> ContactItem {
        let fullname = contact.name.first+" "+contact.name.last
        let largeImageStr = contact.picture.large
        return ContactItem(fullname: fullname, email: contact.email, phone: contact.phone, cell: contact.cell, largeImageStr: largeImageStr, nat: contact.nat, thumbnailString: contact.picture.thumbnail)
    }
    
    private func loadImage(from text: String, type: RequestedImageType, completion: @escaping(Result<Data?, HTTPError>) -> Void) {
        let imageDownloader = ImageDownloadingOperation(imageURLString: text){ result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        switch type {
        case .thumbnail:
            operationStack.push(imageDownloader)
            if operationStack.count() >= 40 {
                for i in stride(from: operationStack.count()-1, through: 0, by: -1) {
                    if i > 20 {
                        guard let imageDownloadingOperation = operationStack.popLast() else { return }
                        imageDownloaderQueue.addOperation(imageDownloadingOperation)
                    } else {
                        guard let imageDownloadingOperation = operationStack.popFirst() else { return }
                        imageDownloadingOperation.cancel()
                    }
                }
            }
        case .large:
            imageDownloaderQueue.addOperation(imageDownloader)
        }
    }
}

extension NetworkService: NetworkServiceProtocol {
    func fetchContactList(number: Int, completion: @escaping(Result<[ContactItem], Error>) -> Void) {
            self.loadContactList(number: number){ (result) in
                    switch result {
                    case .success(let result):
                        let contactItemsArray = result.map{
                            self.createNewContactItem(contact: $0)
                        }
                        completion(.success(contactItemsArray))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        return
    }
    
    func requestImage(urlString: String, type: RequestedImageType, completion: @escaping(Result<Data, Error>) -> Void) {
        let imageData = imageDataCache.lookForImageData(for: urlString)
        switch imageData {
            case .none:
            loadImage(from: urlString, type: type) { result in
                switch result {
                case .success(let data):
                    guard let data = data else { return }
                    self.imageDataCache.insertImageData(data, for: urlString)
                    completion(.success(data))
                    return
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
            case .some(let foundImageData):
                completion(.success(foundImageData))
                return
        }
    }
}
