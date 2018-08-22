//
//  TweetViewController.swift
//  TaskApp
//
//  Created by Олег Максименко on 14.08.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

import UIKit
import SwiftSoup

class TweetViewController: UIViewController, UITableViewDataSource {

    typealias Item = (text: String, html: String)
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var cssTextField: UITextField!
    
    
    var document: Document = Document.init("")
    
    var items: [Item] = []
    var tweets: [Tweet] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = "https://twitter.com/search?q=realdonaldtrump"
        cssTextField.text = "div"
        
        
        tableView.dataSource = self
        downloadHTML()
        //print(items)
    }
    
    
    
    func downloadHTML() {
        
        guard let url = URL(string: urlTextField.text ?? "") else {
            // an error occurred
            //UIAlertController.showAlert("Error: \(urlTextField.text ?? "") doesn't seem to be a valid URL", self)
            return
        }
        
        do {
            // content of url
            let html = try String.init(contentsOf: url)
            // parse it into a Document
            document = try SwiftSoup.parse(html)
            //let d = try document.text()
            let srcs: Elements = try document.select("p.tweet-text")
            let srcs1: Elements = try document.select("strong.u-textTruncate")
            
            var i = 0
            
            for (element,element2) in zip(srcs,srcs1) {
                let text = try element.text()
                let name = try element2.text()
                //print(text)
                tweets.append(Tweet(author: name, tweet_text: text))
            }
            
            // parse css query
            //parse()
        } catch let error {
            // an error occurred
            //UIAlertController.showAlert("Error: \(error)", self)
        }
        
        
        tableView.reloadData()
    }
    
    
    
    //Parse CSS selector
    func parse() {
        do {
            //empty old items
            items = []
            // firn css selector
            let elements: Elements = try document.select(cssTextField.text ?? "")
            //transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                items.append(Item(text: text, html: html))
            }
            
        } catch let error {
            //UIAlertController.showAlert("Error: \(error)", self)
        }
        
        tableView.reloadData()
    }
    
    /*@IBAction func chooseQuery(_ sender: Any) {
        guard let viewController = storyboard?.instantiateViewController(
            withIdentifier: "QueryViewController") as? QueryViewController  else {
                return
        }
        viewController.completionHandler = {[weak self](resilt) in
            self?.navigationController?.popViewController(animated: true)
            self?.cssTextField.text = resilt.example
            self?.parse()
        }
        self.show(viewController, sender: self)
    }*/
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweetcell", for: indexPath) as! TweetTableViewCell
    
        
        let tweet:Tweet = tweets[indexPath.row]
        //print(tweet.author!)
    
        cell.textLabel?.text = tweet.author! + "\n" + tweet.tweet_text!
    
        cell.name.text = tweet.author
        cell.tweet_text.text = tweet.tweet_text
    
        return  cell
    }

}
