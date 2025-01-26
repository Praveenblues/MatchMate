//
//  UserMatchTests.swift
//  UserMatchTests
//
//  Created by Praveen on 24/01/25.
//

import Testing
@testable import UserMatch

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
        sut.declineProfile(userID: sut.users[0].id)
        #expect(sut.users[0].preferenceStatus == .Declined)
        await sut.getMatchingUsers()
        #expect(sut.users[0].preferenceStatus == .Declined)
    }

}
