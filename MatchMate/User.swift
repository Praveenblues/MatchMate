//
//  User.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import Foundation

struct UsersResponse: Decodable {
    var results: [UserDomainModel]?
}
struct UserDomainModel: Decodable {
    var login: LoginDetail?
    var name: NameDetail?
    var location: LocationDetail?
    var picture: PictureDetail?
}
struct NameDetail: Decodable {
    var first: String?
    var last: String?
}
struct LoginDetail: Decodable {
    var uuid: String?
}
struct LocationDetail: Decodable {
    var street: StreetDetail?
    var city: String?
    var state: String?
    var country: String?
}
struct StreetDetail: Decodable {
    var number: UInt64?
    var name: String?
}
struct PictureDetail: Decodable {
    let medium: String?
}


struct UserDataModel: Identifiable {
    var id: String
    var name: String
    var avatarUrl: String?
    var location: String?
    var preferenceStatus: PreferenceStatus?
}
enum PreferenceStatus: Int16 {
    case Accepted
    case Declined
}
