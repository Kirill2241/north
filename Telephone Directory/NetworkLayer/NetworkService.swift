//
//  NetworkService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    var imageData: NetworkServiceImageData?
    var responseData: NetworkServiceCustomData?
    
    func processContactListRequest(_ numberOfResults: Int) -> NetworkServiceCustomData{
        let urlString = "https://randomuser.me/api/?results=\(numberOfResults)&inc=name,phone,cell,email,nat,picture"
        let _: () = loadContactList(number: numberOfResults){ result in
            var networkData: NetworkServiceCustomData{
                switch result{
                case .success(let contactModel):
                    return NetworkServiceCustomData(status: .success)
                case .failure(let error):
                    return NetworkServiceCustomData(status: .error, error: error)
                }
            }
            self.responseData = networkData
        }
        return responseData ?? NetworkServiceCustomData(status: .error, error: HTTPError.httpError(-1))
        /*
        switch result {
        case .failure(let error):
            return NetworkServiceCustomData(status: .error)
        case .success(let requestResp):
            return NetworkServiceCustomData(status: .success, result: requestResp)
        case .none:
            return NetworkServiceCustomData(status: .error)
        }*/
    }
    
    func loadContactList(number: Int, completion: @escaping(Result<[ContactInstance]?, HTTPError>) -> Void){
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
                let correctResponse: ContactModel? = try? JSONDecoder().decode(ContactModel.self, from: data!)
                let array = correctResponse?.results
                completion(.success(array))
            } catch {
                completion(.failure(HTTPError.transportError(error)))
            }
        }.resume()
    }
    
    func requestImage(urlString: String) -> NetworkServiceImageData{
        let _: ()? = loadImage(from: urlString){ result in
            var pictureData: NetworkServiceImageData{
                switch result {
                case .success(let data):
                    return NetworkServiceImageData(status: .success, data: data)
                case .failure(let error):
                    return NetworkServiceImageData(status: .error, error: error)
                }
            }
            self.imageData = pictureData
            /*
             switch result {
             case .failure(let error):
             return NetworkServiceImageData(status: .error, error: error)
             case .success(let data):
             return NetworkServiceImageData(status: .success, data: data)
             case .none:
             return NetworkServiceImageData(status: .noConnection)
             }*/
        }
        return imageData ?? NetworkServiceImageData(status: .error, error: HTTPError.httpError(-1))
    }
    
    func loadImage(from text: String, completion: @escaping(Result<Data?, HTTPError>) -> Void){
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
            } catch {
                completion(.failure(HTTPError.transportError(error)))
            }
        }.resume()
    }
}
