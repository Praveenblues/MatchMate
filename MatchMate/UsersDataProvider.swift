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
    func getMatchingUsers(page: Int) async throws -> [UserDataModel]
}

class UsersDataProvider: UsersDataProviderProtocol {
    var networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getMatchingUsers(page: Int) async throws -> [UserDataModel] {
        guard let url = URL(string: "https://randomuser.me/api/?results=10&page=\(page)") else {return []}
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
            let name = [userDomainModel.name?.first, userDomainModel.name?.last].compactMap({$0}).joined(separator: " ")
            var location = ""
            if let streetNumber = userDomainModel.location?.street?.number {
                location.append("\(streetNumber), ")
            }
            location += [userDomainModel.location?.street?.name,
                            userDomainModel.location?.city,
                            userDomainModel.location?.state,
                            userDomainModel.location?.country]
                .compactMap({$0}).joined(separator: ", ")
            let preferenceStatus = DataManager.getPreferenceStatus(for: id)
            return UserDataModel(id: id,
                                 name: name,
                                 avatarUrl: userDomainModel.picture?.medium,
                                 location: location,
                                 preferenceStatus: preferenceStatus)
        })
    }
}
