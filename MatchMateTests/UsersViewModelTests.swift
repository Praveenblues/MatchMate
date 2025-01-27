//
//  UserMatchTests.swift
//  UserMatchTests
//
//  Created by Praveen on 24/01/25.
//

import Testing
@testable import MatchMate

struct UsersViewModelTests {
    
    var sut: UsersViewModel
    var mockNetworkManager = MockNetworkManager()
    
    init() {
        mockNetworkManager.successDataObject = UsersResponse.mock
        sut = UsersViewModel(usersDataProvider: UsersDataProvider(networkManager: mockNetworkManager))
    }

    @Test func apiResponseIsParsedCorrectly() async throws {
        await sut.getMatchingUsers()
        let users = sut.users
        #expect(users.count == 2)
        #expect(users[0].name == "first last")
        #expect(users[0].id == "1")
        #expect(users[0].location == "1, streetName, city, state, country")
        #expect(users[0].avatarUrl == "avatarUrl")
    }
    
    @Test func apiError() async throws {
        mockNetworkManager.isError = true
        await sut.getMatchingUsers()
        let users = sut.users
        #expect(users.count == 0)
        #expect(sut.showError)
    }
    
    @Test func nextPageTriggered() async throws {
        await sut.getMatchingUsers()
        #expect(sut.currentPage == 1)
        await sut.fetchNextPage()
        #expect(sut.users.count == 4)
        #expect(sut.currentPage == 2)
    }
    
    @Test func noStreetNumber() async throws {
        mockNetworkManager.successDataObject = UsersResponse.mock2
        await sut.getMatchingUsers()
        let users = sut.users
        #expect(users.count == 1)
        #expect(users[0].location == "streetName, city, state, country")
    }
    
    @Test func acceptProfileAction() async throws {
        await sut.getMatchingUsers()
        sut.acceptProfile(userID: sut.users[0].id)
        #expect(sut.users[0].preferenceStatus == .Accepted)
        await sut.getMatchingUsers()
        #expect(sut.users[0].preferenceStatus == .Accepted)
    }
    
    @Test func declineProfileAction() async throws {
        await sut.getMatchingUsers()
        sut.declineProfile(userID: sut.users[1].id)
        #expect(sut.users[1].preferenceStatus == .Declined)
        await sut.getMatchingUsers()
        #expect(sut.users[1].preferenceStatus == .Declined)
    }

}
