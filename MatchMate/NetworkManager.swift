//
//  NetworkManager.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import Foundation

protocol NetworkManagerProtocol {
    func getData<T: Decodable>(of type: T.Type, urlRequest: URLRequest) async throws -> T
}


class NetworkManager: NetworkManagerProtocol {
//    var dataManager: DataManager
    
//    init(dataManager: DataManager = DataManager()) {
//        self.dataManager = dataManager
//    }
    
    func getData<T>(of type: T.Type, urlRequest: URLRequest) async throws -> T where T : Decodable {
        let urlString = urlRequest.url?.absoluteString
        do {
            let (data,_) = try await URLSession.shared.data(for: urlRequest)
            if let urlString = urlString {
                try DataManager.cacheResponse(response: data, for: urlString)
            }
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            if (error as? URLError)?.errorCode == -1009,
               let urlString = urlString,
               let data = try DataManager.getCachedResponse(for: urlString) {
                return try JSONDecoder().decode(type, from: data)
            }
            throw error
        }
    }
}
