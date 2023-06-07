//
//  CoreDataManager.swift
//  Core Data ToDoList
//
//  Created by KhoiLe on 07/06/2023.
//

import Foundation
import UIKit
import CoreData

final public class CoreDataManager {
    public static let shared = CoreDataManager()
    
    let context: NSManagedObjectContext
    
    init() {
        // Get the NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        
        // Config data protection
        let persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        let storeOptions = [NSPersistentStoreFileProtectionKey: FileProtectionType.complete]
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.setOption(storeOptions as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        persistentStoreCoordinator.addPersistentStore(with: storeDescription, completionHandler: { (storeDescription, error) in
            if let error = error {
                // Handle error during persistent store setup
                print("Error setting up persistent store: \(error)")
            } else {
                // Successful setup
                print("Persistent store setup successful")
            }
        })
    }
    
    func getAllItems() -> [ToDoListItem] {
        do {
            return try context.fetch(ToDoListItem.fetchRequest())
        } catch {
            print("Cannot fetch data from Core Data")
            return []
        }
    }
    
    func createItem(name: String, completion: @escaping (() -> Void)) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            var items = getAllItems()
            items.append(newItem)
            try context.save()
        } catch {
            print("Cannot save new item to Core Data")
        }
        completion()
    }
    
    func deleteItem(item: ToDoListItem, completion: @escaping (() -> Void)) {
        do {
            var items = getAllItems()
            context.delete(item)
            try context.save()
        } catch {
            print("Cannot delete the item from Core Data")
        }
        completion()
    }
    
    func updateItem(item: ToDoListItem, newName: String, completion: @escaping (() -> Void)) {
        item.name = newName
        
        do {
            try context.save()
        } catch {
            print("Cannot update the item from Core Data")
        }
        completion()
    }
    
}
