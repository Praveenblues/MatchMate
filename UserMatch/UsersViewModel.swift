//
//  MatchesViewModel.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import Foundation

class UsersViewModel: ObservableObject {
    
    @Published var users: [UserDataModel] = []
    @Published var showError: Bool = false
    lazy var errorMessage = ""
    
    var usersDataProvider: UsersDataProviderProtocol
//    var dataManager: DataManager
    
    init(usersDataProvider: UsersDataProviderProtocol = UsersDataProvider()) {
        self.usersDataProvider = usersDataProvider
//        self.dataManager = dataManager
    }
    
    func getMatchingUsers() async {
        do {
            let users = try await usersDataProvider.getMatchingUsers()
            await MainActor.run {
                self.users = users
            }
        } catch {
            print("ERROR: \(error)")
            guard let error = error as? UsersListError else { return }
            switch error {
            case .NoNetwork:
                errorMessage = "Please check your internet connection"
            case .Unknown:
                errorMessage = "Sorry, an error occurred"
            }
            showError = true
        }
    }
    
    func acceptProfile(userID: String) {
        do {
            try DataManager.setPreferenceStatus(userID: userID, preferenceStatus: .Accepted)
            if let index = users.firstIndex(where: {$0.id == userID}) {
                users[index].preferenceStatus = .Accepted
            }
        } catch {
            print("Error: \(error)")
            errorMessage = "Sorry, an error occurred"
            showError = true
        }
    }
    
    func declineProfile(userID: String) {
        do {
            try DataManager.setPreferenceStatus(userID: userID, preferenceStatus: .Declined)
            if let index = users.firstIndex(where: {$0.id == userID}) {
                users[index].preferenceStatus = .Declined
            }
        } catch {
            print("Error: \(error)")
            errorMessage = "Sorry, an error occurred"
            showError = true
        }
    }
}
