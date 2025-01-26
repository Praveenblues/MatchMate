//
//  MockNetworkManager.swift
//  UserMatch
//
//  Created by Praveen on 26/01/25.
//

import Foundation
@testable import UserMatch

class MockNetworkManager: NetworkManagerProtocol {
    var successDataObject: Decodable
    
    init(successDataObject: Decodable = Data()) {
        self.successDataObject = successDataObject
    }
    func getData<T>(of type: T.Type, urlRequest: URLRequest) async throws -> T where T : Decodable {
        if let dataObject = successDataObject as? T {
            return dataObject
        } else {
            throw URLError(.unknown)
        }
    }
}
