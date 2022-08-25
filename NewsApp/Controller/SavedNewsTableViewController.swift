//
//  SavedNewsTableViewController.swift
//  NewsApp
//
//  Created by valters.steinblums on 25/08/2022.
//

import UIKit
import CoreData
import SDWebImage

class SavedNewsTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext?
    var savedNews = [News]()
    var articles: [Article] = []
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        loadData()
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        isEditing = !isEditing
        
        switch isEditing {
        case true:
            editButton.image = UIImage.init(systemName: "checkmark.rectangle.portrait.fill")
        case false:
            editButton.image = UIImage.init(systemName: "arrow.up.arrow.down.square.fill")
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<News> = News.fetchRequest()
        
        do {
            request.sortDescriptors = [NSSortDescriptor(key: "rowOrder", ascending: true)]
            
            if let result = try managedObjectContext?.fetch(request) {
//                for savedNews in result as [NSManagedObject] {
//                    print(savedNews.value(forKey: "newsTitle") as! String)
//                    print(savedNews.value(forKey: "newsDescription") as! String)
//                    print(savedNews.value(forKey: "newsImage") as! String)
//                }
                savedNews = result
                self.tableView.reloadData()
            }
        } catch {
            print("Error in loading core data items.")
        }
    }
    
    func saveData() {
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error in loading core data items.")
        }
        loadData()
    }
    
    
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete items", message: "Do you really want to delete all items from the list?", preferredStyle: .alert)
        
        let addDeleteButton = UIAlertAction(title: "Delete", style: .destructive) { action in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.managedObjectContext?.execute(batchDeleteRequest)
            } catch {
                print("Error in the batch delete!!!")
            }
            self.saveData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(addDeleteButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if savedNews.count == 0 {
            tableView.backgroundView = UIImageView(image: UIImage(named: "empty"))
            
            tableView.backgroundView?.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tableView.backgroundView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            tableView.backgroundView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            tableView.backgroundView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        }
        
        return savedNews.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedNewsCell", for: indexPath)

        let savedArticle = savedNews[indexPath.row]
        
        cell.textLabel?.text = savedArticle.value(forKey: "newsTitle") as? String
        cell.detailTextLabel?.text = savedArticle.value(forKey: "newsDescription") as? String
//        cell.imageView?.sd_setImage(with: URL(string: (savedArticle.value(forKey: "newsImage") as? String)!)!)
        

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 300
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            managedObjectContext?.delete(savedNews[indexPath.row])
        }
        saveData()
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let newsArticleToMove = savedNews[fromIndexPath.row]
        
        savedNews.remove(at: fromIndexPath.row)
        savedNews.insert(newsArticleToMove, at: destinationIndexPath.row)
        
        for (newValue, item) in savedNews.enumerated() {
            item.setValue(newValue, forKey: "rowOrder")
        }
        
        tableView.reloadData()
        saveData()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let savedArticle = savedNews[indexPath.row]
//        Saved article passed to detailed view something...
        vc.saved = savedArticle
        vc.isFromViewController = "SavedFeed"
        show(vc, sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
