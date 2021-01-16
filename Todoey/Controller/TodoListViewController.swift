//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            self.loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = selectedCategory?.name
                        
        self.loadItems()
    
    }

    
    //MARK: - TableViewDataSource Methods
    
    //método onde informamos o número de linhas que o ListController deve ter
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //elemento da célula que será exibido a cada passagem do foreach no array de elementos do tablecontroller
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "TodoItemCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ?
            .checkmark :
            .none
        
        /*
             if item.done == true {
                 cell.accessoryType = .checkmark
             }else{
                 cell.accessoryType = .none
             }
         */
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
        
    //método executado ao selecionasr uma linha do table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Para remover um item do core data, removemos o item do core data e depois do array da tela
        // context.delete(itemArray[indexPath.row])
        // itemArray.remove(at: indexPath.row)
        
        /*
             ugly method
             if itemArray[indexPath.row].done == false {
                 itemArray[indexPath.row].done = true
             }else{
                 itemArray[indexPath.row].done = false
             }
         */
        
        // verifica se a linha selecionada tem um accessoryType (checked simbol)
        tableView.cellForRow(at: indexPath)?.accessoryType =
            tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark ?
            .checkmark :
            .none
        
        /*
             if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                 tableView.cellForRow(at: indexPath)?.accessoryType = .none
             }else{
                 tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
             }
         */
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.saveData()
        
    }
    
    //swipe lateral direito trailingSwipeActionsConfigurationForRowAt
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //acao 1
        //podemos adicionar acoes para o swipe lateral aqui
        let trash = UIContextualAction(style: .destructive, title: "Remover") { (action, vieew, completionHandler) in
            
            //remove o elemento do contexto
            //entao remove do array de dados
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            
            //recarrega tela
            self.loadItems()
            
        }
        
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])
        
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
        
    }
    
    
    //MARK: -  Add new itens
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField  = UITextField()
        
        let alert = UIAlertController(title: "Adicione um novo item", message: "Subtítulo", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            DispatchQueue.main.async {
                
                let item = Item(context: self.context)
                item.title = textField.text!
                item.done = false
                item.parentCategory = self.selectedCategory
                
                self.itemArray.append(item)
                
                //metodo para salvar dados locais do telefone. Dados básicos
                //self.defaults.set(self.itemArray, forKey: "TodoListArray")
                
                self.saveData()
                
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Informe o item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: -  Data
    
    func saveData() -> Void {
        //metodo para salvar os dados no arquivo do telefone
       
        // para uso de plists files com dataFilePath
        // let encoder = PropertyListEncoder()
        
        do {
            
            try context.save()
            
            // para uso de plists files com dataFilePath
            // let data = try encoder.encode(self.itemArray)
            // try data.write(to: self.dataFilePath!)
            
        }catch{
            
            print("Error saving context \(error)")
            
            // para uso de plists files com dataFilePath
            // print("error encoding value of array \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), and predicate: NSPredicate? = nil ) -> Void{
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
    
        
        do {
            itemArray = try context.fetch(request)
        }catch{
            print("Error when fetching data \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: -  SearchBar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(with: request, and: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            
            // tirar o foco do componente
            // aqui o comando de tirar o foco é executado em background
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

