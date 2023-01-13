//
//  NetworkService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    
    func prepareNetworkResponseForPresentation(number: Int, completion: @escaping(([ContactItem]?, ContactListDownloadStatus)) -> Void) {
            self.loadContactList(number: number){ (result) in
                    switch result {
                    case .success(let result):
                        var contactItemsArray: [ContactItem] = []
                        guard let result = result else { return }
                        for i in 0...result.count-1{
                            contactItemsArray.append(self.createNewContactItem(contact: result[i]))
                        }
                        completion((contactItemsArray, .success))
                    case .failure(_):
                        completion((nil, .failure))
                }
            }
        return
    }
    
    private func loadContactList(number: Int, completion: @escaping(Result<[OneContactNetworkResponse]?, HTTPError>) -> Void) {
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
                let array = correctResponse?.results
                completion(.success(array))
            }
        }.resume()
    }
    
    private func createNewContactItem(contact: OneContactNetworkResponse) -> ContactItem {
        let fullname = contact.name.first+" "+contact.name.last
        let largeImageStr = contact.picture.large
        return ContactItem(fullname: fullname, email: contact.email, phone: contact.phone, cell: contact.cell, largeImageStr: largeImageStr, nat: contact.nat, thumbnailString: contact.picture.thumbnail)
    }
    
    func requestImage(urlString: String, completion: @escaping(Data?) -> Void) {
        loadImage(from: urlString) { result in
            switch result {
            case .success(let data):
                completion(data)
                return
            case .failure(_):
                completion(nil)
                return
            }
        }
    }
    
    private func loadImage(from text: String, completion: @escaping(Result<Data?, HTTPError>) -> Void) {
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
