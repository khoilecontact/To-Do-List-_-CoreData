//
//  ViewController.swift
//  Core Data ToDoList
//
//  Created by KhoiLe on 29/08/2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let context: NSPersistentContainer!
    
    private var items = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Core Data To Do List"
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        getAllItems()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        let item = self.items[indexPath.row]
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit Your Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?[0].text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let text = alert.textFields?[0].text else {
                    return
                }
                
                self?.updateItem(item: item, newName: text)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            self.deleteItem(item: item)
        }))
        present(sheet, animated: true)
        
    }
    
    @objc func didTapAdd() {
        let alert = UIAlertController(title: "New", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let text = alert.textFields?[0].text else {
                return
            }
            
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }
    
    func getAllItems() {
        do {
            items = try context.fetch(ToDoListItem.fetchRequest())
        } catch {
            print("Cannot fetch data from Core Data")
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            items.append(newItem)
            getAllItems()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Cannot save new item to Core Data")
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print("Cannot delete the item from Core Data")
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Cannot update the item from Core Data")
        }
    }


}

