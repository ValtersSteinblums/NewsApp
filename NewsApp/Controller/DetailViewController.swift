//
//  DetailViewController.swift
//  NewsApp
//
//  Created by valters.steinblums on 25/08/2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var item: Article?
    var savedNews = [News]()
    var saved: News?
    var exists: Bool?
    var isFromViewController: String = ""
    
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.isFromViewController == "NewsFeed" {
            self.title = item?.author
            titleLabel.text = item?.title
            descLabel.text = item?.articleDescription
            newsImageView.sd_setImage(with: URL(string: item?.urlToImage ?? ""))
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            managedObjectContext = appDelegate.persistentContainer.viewContext
            
            let alreadySaved = checkIfExists()
            changeFavouriteButtonState(isSaved: alreadySaved)
            
            print("HELLO FROM FEED")
        }
        
        
        if self.isFromViewController == "SavedFeed" {
            
            titleLabel.text = saved?.newsTitle
            descLabel.text = saved?.newsDescription
            newsImageView.sd_setImage(with: URL(string: saved?.newsImage ?? ""))
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            managedObjectContext = appDelegate.persistentContainer.viewContext
            
            changeFavouriteButtonState(isSaved: true)
            
            print("HELLO FROM FAVES")
        }
        
        loadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<News> = News.fetchRequest()
        
        do {
            if let result = try managedObjectContext?.fetch(request) {
                savedNews = result
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
    
    //    https://stackoverflow.com/questions/37938722/how-to-implement-share-button-in-swift
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if self.isFromViewController == "NewsFeed" {
            let shareNewsArticleVC = UIActivityViewController(activityItems: [item?.url ?? ""], applicationActivities: nil)
            shareNewsArticleVC.popoverPresentationController?.sourceView = sender
            present(shareNewsArticleVC, animated: true, completion: nil)
            shareNewsArticleVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed  {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        if self.isFromViewController == "SavedFeed" {
            let shareNewsArticleVC = UIActivityViewController(activityItems: [saved?.newsURL ?? ""], applicationActivities: nil)
            shareNewsArticleVC.popoverPresentationController?.sourceView = sender
            present(shareNewsArticleVC, animated: true, completion: nil)
            shareNewsArticleVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed  {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        loadData()
        if self.isFromViewController == "NewsFeed" {
            let alreadySaved = checkIfExists()
            switch alreadySaved {
            case true:
                let request: NSFetchRequest<News> = News.fetchRequest()
                do {
                    // when core data is empty, returns nil. Any workarounds...?
                    if let result = try managedObjectContext?.fetch(request) {
                        for savedNews in result as [NSManagedObject] {
                            if (savedNews.value(forKey: "newsTitle") as! String) == item?.title {
                                managedObjectContext?.delete(savedNews)
                            }
                        }
                    }
                } catch {
                    print("Something went wrong removing favourites from detail view")
                }
                changeFavouriteButtonState(isSaved: false)
                print("REMOVE SAVE PRESSED: ", savedNews)
            case false:
                if let entity = NSEntityDescription.entity(forEntityName: "News", in: self.managedObjectContext!) {
                    let article = NSManagedObject(entity: entity, insertInto: self.managedObjectContext)
                    article.setValue(item?.articleDescription, forKey: "newsDescription")
                    article.setValue(item?.title, forKey: "newsTitle")
                    article.setValue(item?.urlToImage, forKey: "newsImage")
                    article.setValue(item?.url, forKey: "newsURL")
                }
                changeFavouriteButtonState(isSaved: true)
                print("SAVE PRESSED: ", savedNews)
            }
        }
        if self.isFromViewController == "SavedFeed" {
            let request: NSFetchRequest<News> = News.fetchRequest()
            do {
                // when core data is empty, returns nil. Any workarounds...?
                if let result = try managedObjectContext?.fetch(request) {
                    for savedNews in result as [NSManagedObject] {
                        if (savedNews.value(forKey: "newsTitle") as! String) == saved?.newsTitle {
                            managedObjectContext?.delete(savedNews)
                        }
                    }
                }
            } catch {
                print("Something went wrong removing favourites from detail view")
            }
            changeFavouriteButtonState(isSaved: false)
            //            https://stackoverflow.com/questions/28760541/programmatically-go-back-to-previous-viewcontroller-in-swift
            _ = navigationController?.popViewController(animated: true)
            print("REMOVE SAVE PRESSED: ", savedNews)
        }
        self.saveData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dVC: WebViewController = segue.destination as? WebViewController else {return}
        
        if self.isFromViewController == "NewsFeed" {
            dVC.urlString = item?.url ?? ""
        } else {
            dVC.urlString = saved?.newsURL ?? ""
        }
        
    }
    
    func checkIfExists() -> Bool {
        let request: NSFetchRequest<News> = News.fetchRequest()
        do {
            // when core data is empty, returns nil. Any workarounds...?
            if let result = try managedObjectContext?.fetch(request) {
                for savedNews in result as [NSManagedObject] {
                    if (savedNews.value(forKey: "newsTitle") as! String) == item?.title {
                        print("ALREADY EXISTS!!!")
                        exists = true
                    } else {
                        exists = false
                        print("GO AHEAD ADD TO FAVES!!!")
                    }
                }
            }
        } catch {
            print("Something went wrong comapring")
        }
        print(exists ?? "HUH.. WHY NIL?")
        // probably this is not a good idea...
        return exists ?? false
    }
    
    func changeFavouriteButtonState(isSaved: Bool) {
        switch isSaved {
        case true:
            saveButton.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
        case false:
            saveButton.setImage(UIImage.init(systemName: "heart"), for: .normal)
        }
        saveData()
    }
    
    
}
