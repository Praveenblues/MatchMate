//
//  MatchesViewModel.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import Foundation

enum ScreenState {
    case Loading
    case Data
}

@MainActor
class UsersViewModel: ObservableObject {
    
    @Published var users: [UserDataModel] = []
    @Published var showError: Bool = false
    var screenState: ScreenState = .Loading
    lazy var errorMessage = ""
    
    private var currentPage = 1
    private var usersDataProvider: UsersDataProviderProtocol
    
    init(usersDataProvider: UsersDataProviderProtocol = UsersDataProvider()) {
        self.usersDataProvider = usersDataProvider
    }
    
    func getMatchingUsers() async {
        print("trigger getMatchingUsers, \(currentPage)")
        do {
            let users = try await usersDataProvider.getMatchingUsers(page: currentPage)
            print("giot users \(users.first!.id)")
            await MainActor.run {
                self.users.append(contentsOf: users)
                self.screenState = .Data
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
            await MainActor.run {
                showError = true
            }
        }
    }
    
    func fetchNextPage() async {
        currentPage += 1
        await getMatchingUsers()
    }
    
    
    //MARK: Card actions
    
    var isBulkEnabled = false
    
    var selectedUsers: [UserDataModel] {
        users.filter({$0.isSelected})
    }
    
    func acceptProfile(userID: String) {
        Task {
            do {
                try await DataManager.setPreferenceStatus(userID: userID, preferenceStatus: .Accepted)
                if let index = users.firstIndex(where: {$0.id == userID}) {
                    await MainActor.run {
                        users[index].preferenceStatus = .Accepted
                    }
                }
            } catch {
                print("Error: \(error)")
                errorMessage = "Sorry, an error occurred"
                showError = true
            }
        }
    }
    
    func declineProfile(userID: String) {
        Task {
            do {
                try await DataManager.setPreferenceStatus(userID: userID, preferenceStatus: .Declined)
                if let index = users.firstIndex(where: {$0.id == userID}) {
                    await MainActor.run {
                        users[index].preferenceStatus = .Declined
                    }
                }
            } catch {
                print("Error: \(error)")
                errorMessage = "Sorry, an error occurred"
                showError = true
            }
        }
    }
    
    func cardTapped(id: String) {
        if isBulkEnabled {
            cardLongPressed(id: id)
        }
    }
    
    func cardLongPressed(id: String) {
        isBulkEnabled = true
        if let index = users.firstIndex(where: {$0.id == id}) {
            users[index].isSelected = true
        }
    }
    
    //MARK: Navbar actions
    
    func cancelTapped() {
        users = users.map({user in
            var userCopy = user
            userCopy.isSelected = false
            return userCopy
        })
        isBulkEnabled = false
    }
    
    func bulkAccept() {
        for id in selectedUsers.map({$0.id}) {
            acceptProfile(userID: id)
        }
        cancelTapped()
    }
    
    func bulkDecline() {
        for id in selectedUsers.map({$0.id}) {
            declineProfile(userID: id)
        }
        cancelTapped()
    }
}
