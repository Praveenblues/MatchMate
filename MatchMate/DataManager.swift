//
//  DataManager.swift
//  UserMatch
//
//  Created by Praveen on 25/01/25.
//

import CoreData

class DataManager {
    
    static var viewContext = PersistenceController.shared.container.viewContext
    
    static func getCachedResponse(for url: String) throws -> Data? {
        let fetchRequest = NSFetchRequest<UrlData>(entityName: "UrlData")
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        return try viewContext.fetch(fetchRequest).first?.value
    }
    
    static func cacheResponse(response: Data, for url: String) throws {
        //  If this url's data is already cached, just update the response data
        let fetchRequest = NSFetchRequest<UrlData>(entityName: "UrlData")
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        let results = try viewContext.fetch(fetchRequest)
        if !results.isEmpty {
            results.first?.value = response
        } else {
            let newUrlDataItem = UrlData(context: viewContext)
            newUrlDataItem.value = response
            newUrlDataItem.url = url
        }
        try viewContext.save()
    }
    
    static func getPreferenceStatus(for userID: String) -> PreferenceStatus? {
        let fetchRequest = NSFetchRequest<Preferences>(entityName: "Preferences")
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        var preferenceStatus: PreferenceStatus? = nil
        viewContext.performAndWait {
            guard let results = try? viewContext.fetch(fetchRequest) else {
                return
            }
            guard let preference = results.first(where: {$0.userID == userID})?.preference,
                  let preferenceStatusFromDB = PreferenceStatus(rawValue: preference) else {
                return
            }
            preferenceStatus = preferenceStatusFromDB
        }
        return preferenceStatus
    }
    
    static func setPreferenceStatus(userID: String, preferenceStatus: PreferenceStatus) async throws {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = viewContext
        
        let fetchRequest = NSFetchRequest<Preferences>(entityName: "Preferences")
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        try await viewContext.perform {
            let results = try viewContext.fetch(fetchRequest)
            if !results.isEmpty {
                results.first?.preference = preferenceStatus.rawValue
            } else {
                let newPreference = Preferences(context: viewContext)
                newPreference.userID = userID
                newPreference.preference = preferenceStatus.rawValue
            }
            try viewContext.save()
        }
    }
    
}
