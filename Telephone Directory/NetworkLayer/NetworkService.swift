//
//  NetworkService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func loadContactList(urlString: String) async -> Result<ContactModel?, HTTPError>
    func processContactListRequest(_ numberOfResults: Int, fields: [String]) async -> NetworkServiceCustomData
    func requestImage(urlString: String) async -> NetworkServiceImageData
}

class NetworkService: NetworkServiceProtocol {
    
    func processContactListRequest(_ numberOfResults: Int, fields: [String]) async -> NetworkServiceCustomData{
        var urlString = "https://randomuser.me/api/?"
        var components = "results=\(numberOfResults)&inc="
        for i in 0...fields.count-1{
            if i == fields.count-1{
                components += fields[i]
            }else{
                components += fields[i]+","
            }
        }
        urlString += components
        let result = try? await loadContactList(urlString: urlString)
        switch result {
        case .failure(let error):
            return NetworkServiceCustomData(status: .error)
        case .success(let requestResp):
            return NetworkServiceCustomData(status: .success, result: requestResp)
        case .none:
            return NetworkServiceCustomData(status: .error)
        }
    }
    
    func loadContactList(urlString: String) async -> Result<ContactModel?, HTTPError> {
        await withCheckedContinuation{ continuation in
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                continuation.resume(returning: .failure(HTTPError.transportError(error)))
                return
            }
            let resp = response as! HTTPURLResponse
            let status = resp.statusCode
            guard (200...299).contains(status) else {
                continuation.resume(returning: .failure(HTTPError.httpError(status)))
                return
            }
            let correctResponse: ContactModel? = try? JSONDecoder().decode(ContactModel.self, from: data!)
            continuation.resume(returning: .success(correctResponse))
        }.resume()
        }
    }
    
    func requestImage(urlString: String) async -> NetworkServiceImageData{
        let result = try? await loadImage(from: urlString)
        switch result {
        case .failure(let error):
            return NetworkServiceImageData(status: .error, error: error)
        case .success(let data):
            return NetworkServiceImageData(status: .success, data: data)
        case .none:
            return NetworkServiceImageData(status: .noConnection)
        }
    }
    
    func loadImage(from text: String) async -> Result<Data?, HTTPError>{
        await withCheckedContinuation{ continuation in
            guard let photoUrl = URL(string: text) else { return }
            let request = URLRequest(url: photoUrl)
            URLSession.shared.dataTask(with: request){ data, response, error in
                if let error = error {
                    continuation.resume(returning: .failure(HTTPError.transportError(error)))
                    return
                }
                let resp = response as! HTTPURLResponse
                let status = resp.statusCode
                guard (200...299).contains(status) else {
                    continuation.resume(returning: .failure(HTTPError.httpError(status)))
                    return
                }
                let correctResponse: Data? = data
                continuation.resume(returning: .success(correctResponse))
            }.resume()
        }
    }
}
