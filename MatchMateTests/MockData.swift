//
//  MockData.swift
//  UserMatch
//
//  Created by Praveen on 26/01/25.
//

@testable import UserMatch

extension UsersResponse {
    static let mock: UsersResponse = UsersResponse(results: [
        UserDomainModel(login: LoginDetail(uuid: "1"), name: NameDetail(first: "first", last: "last"), location: LocationDetail(street: StreetDetail(number: 1, name: "streetName"), city: "city", state: "state", country: "country"), picture: PictureDetail(medium: "avatarUrl")),
        UserDomainModel(login: LoginDetail(uuid: "2"), name: NameDetail(first: "first2", last: "last2"), location: LocationDetail(street: StreetDetail(number: 1, name: "streetName2"), city: "city2", state: "state2", country: "country2"), picture: PictureDetail(medium: "medium2"))
    ])
    static let mock2: UsersResponse = UsersResponse(results: [
        UserDomainModel(login: LoginDetail(uuid: "1"), name: NameDetail(first: "first", last: "last"), location: LocationDetail(street: StreetDetail(name: "streetName"), city: "city", state: "state", country: "country"), picture: PictureDetail(medium: "avatarUrl"))
    ])
}
