//
//  UsersDataProvider.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import Foundation

enum UsersListError: Error {
    case NoNetwork
    case Unknown
}

protocol UsersDataProviderProtocol {
    func getMatchingUsers() async throws -> [UserDataModel]
}

class UsersDataProvider: UsersDataProviderProtocol {
    var networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getMatchingUsers() async throws -> [UserDataModel] {
        // &seed=aa5695b99e2fb13c
        guard let url = URL(string: "https://randomuser.me/api/?results=10&page=1") else {return []}
        do {
            let response = try await networkManager.getData(of: UsersResponse.self, urlRequest: URLRequest(url: url))
            return getMatchingUsersDataModels(domainModels: response.results)
        } catch {
            if (error as? URLError)?.errorCode == -1009 {
                throw UsersListError.NoNetwork
            } else {
                throw UsersListError.Unknown
            }
        }
    }
    
    private func getMatchingUsersDataModels(domainModels: [UserDomainModel]?) -> [UserDataModel] {
        guard let domainModels = domainModels else { return [] }
        return domainModels.compactMap({ userDomainModel in
            guard let id = userDomainModel.login?.uuid else {return nil}
            let preferenceStatus = DataManager.getPreferenceStatus(for: id)
            return UserDataModel(id: id,
                                 name: userDomainModel.name?.first ?? "",
                                 avatarUrl: userDomainModel.picture?.medium,
                                 location: userDomainModel.location?.country,
                                 preferenceStatus: preferenceStatus)
        })
    }
}
