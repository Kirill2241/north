//
//  NetworkService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class NetworkService {
    var imageDownloaderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
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
    
    private func loadImage(from text: String, index: Int, completion: @escaping(Result<Data?, HTTPError>) -> Void) {
        let imageDownloader = ImageDownloader(imageURLString: text, index: index)
        imageDownloader.completionBlock = {
            guard let result = imageDownloader.result else { return }
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
        imageDownloaderQueue.addOperation(imageDownloader)
    }
    
}

extension NetworkService: NetworkServiceProtocol{
    
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
    
    func requestImage(urlString: String, index: Int, completion: @escaping(Result<Data, Error>) -> Void) {
        loadImage(from: urlString, index: index) { result in
            switch result {
            case .success(let data):
                guard let data = data else { return }
                completion(.success(data))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
}
