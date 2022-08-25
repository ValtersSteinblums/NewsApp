//
//  ViewController.swift
//  NewsApp
//
//  Created by valters.steinblums on 24/08/2022.
//

import UIKit
import SDWebImage

class NewsFeedViewController: UIViewController {
    
    var articles: [Article] = []
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.fetchData { articles in
            self.articles = articles
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        basicAlert(title: "News feed application", message: "News feed that allows quick glance on the recent news, with the option to visit the whole article in the browser.")
    }
    
    
}

extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell() }
        
        let item = articles[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsImageView.sd_setImage(with: URL(string: item.urlToImage ?? ""))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = articles[indexPath.row]
        vc.item = item
        vc.isFromViewController = "NewsFeed"
        //        present(vc, animated: true)
        show(vc, sender: self)
    }
    
    
}

extension NewsFeedViewController {
    func basicAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let basicAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default)
            basicAlert.addAction(okAction)
            
            self.present(basicAlert, animated: true)
        }
    }
}

