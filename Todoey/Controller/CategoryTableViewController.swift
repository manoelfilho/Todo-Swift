//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Manoel Filho on 14/10/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    //lista de categorias para o table View Controller
    var categoryArray = [Category]()
    
    //Primeiro eu preciso do contexto da aplicacao para salvar os dados do core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        //carrega os dados que já existem no core data // se existirem
        self.loadItems()
    }

    //MARK: - Modal para novo item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField  = UITextField()
        let alert = UIAlertController(title: "Adicione uma nova categoria", message: "Cada categoria pode ter nenhuma ou diversas tarefas", preferredStyle: .alert)
        let action = UIAlertAction(title: "Adicionar", style: .default) { (action) in
            DispatchQueue.main.async {
                
                let category = Category(context: self.context)
                category.name = textField.text!
                
                self.categoryArray.append(category)
                
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
    
    //método onde informamos o número de linhas que o TableViewListController deve ter
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    
    //MARK: - TableView Delegate Methods
    
    //elemento da célula que será exibido a cada passagem do foreach no array de elementos do tablecontroller
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
        
    //método executado ao selecionar uma linha do table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //swipe lateral direito trailingSwipeActionsConfigurationForRowAt
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //acao 1
        //podemos adicionar acoes para o swipe lateral aqui
        let trash = UIContextualAction(style: .destructive, title: "Remover") { (action, vieew, completionHandler) in
            
            //remove o elemento do contexto
            //entao remove do array de dados
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            
            //recarrega tela
            self.loadItems()
            
        }
        
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])
        
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
        
    }
    
    //metodo executado antes do performSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationViewController.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: -  Data
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) -> Void{
        do {
            categoryArray = try context.fetch(request)
        }catch{
            print("Error when fetching data \(error)")
        }
        tableView.reloadData()
    }
        
    func saveData() -> Void {
        do {
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
    }

}
