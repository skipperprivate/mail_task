//
//  TweetViewController.swift
//  TaskApp
//
//  Created by Олег Максименко on 14.08.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

import UIKit
import SwiftSoup
import CoreData


let cache = NSCache<NSString, AnyObject>()
class TweetViewController: UIViewController, UITableViewDataSource {

    typealias Item = (text: String, html: String)
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var urlTextField: UITextField!
    //@IBOutlet weak var cssTextField: UITextField!
    @IBOutlet weak var time_label: UILabel!
    
    @IBOutlet weak var search_btn: UIButton!
    
    var document: Document = Document.init("")
    
    var items: [NSManagedObject] = []
    var tweets: [Tweet] = []
    
    
    
    var urls: [String] = []
    
    let defaults = UserDefaults.standard
    
    var tweet_Timer: Timer!
    
    var time = 60
    
    var url = "https://twitter.com/"
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = ""
        
        tableView.dataSource = self
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tweet_obj")
        
        /*let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet_obj")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There was an error")
        }*/
        
        do {
            items = try managedContext.fetch(fetchRequest)
            
            //var t:Tweet?
            //var k = 0
            for i in items {
                var name = i.value(forKey: "name") as! String
                var url  = i.value(forKey: "image_url")  as! String
                var text = i.value(forKey: "text")  as! String
                tweets.append(Tweet(author: name, tweet_text: text, url: url))
            }
            
            /*let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet_obj")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
            } catch {
                print ("There was an error")
            }*/
            
        } catch{
            
        }
        
        tableView.reloadData()
        
    }
    
    
    func save(name:String, text:String, url: String){
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = app.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Tweet_obj", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        
        item.setValue(name, forKey: "name")
        item.setValue(text, forKey: "text")
        item.setValue(url, forKey: "image_url")
        
        do {
            try managedContext.save()
            
        } catch{
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tweet_Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TweetViewController.iterate), userInfo: nil, repeats: true)
        
        /*for i in tweets{
            save(name: i.author, text: i.tweet_text, url: i.image_url)
        }*/
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tweet_Timer.invalidate()
        
        /*guard let app = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = app.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet_obj")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There was an error")
        }
        
        for i in tweets{
            save(name: i.author, text: i.tweet_text, url: i.image_url)
        }*/
        
        //tweet_in_core.append(<#T##newElement: NSManagedObject##NSManagedObject#>)
    }
    
    
    
    @objc func iterate(){
        time -= 1
        time_label.text = String(time)
        
        if time == 0 {
            time = 60
            
            tweets.removeAll()
            tableView.reloadData()
            
            downloadHTML()
        }
    }
    
    
    
    
    @IBAction func search(_ sender: UIButton) {
        
        time = 60
        
        tweets.removeAll()
        tableView.reloadData()
        self.urls.removeAll()
        
        url = "https://twitter.com/" + urlTextField.text!
        
        downloadHTML()
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = app.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet_obj")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There was an error")
        }
        
        for i in tweets{
            save(name: i.author, text: i.tweet_text, url: i.image_url)
        }
     
    }
    
    
    
    func downloadHTML() {
        
        guard let url2 = URL(string: self.url ?? "") else {
            
            return
        }
        
        do {
            // content of url
            let html = try String.init(contentsOf: url2)
            // parse it into a Document
            document = try SwiftSoup.parse(html)
            //let d = try document.text()
            let srcs: Elements = try document.select("p.tweet-text")
            let srcs1: Elements = try document.select("strong.u-textTruncate")
            let image_srcs: Elements = try document.select("img.js-action-profile-avatar")
            
            for img in image_srcs {
                let url1 = try img.attr("src")
                //print(url1)
                self.urls.append(url1)
                //print(url)
            }
            
            var i = 0
            
            for (element,element2) in zip(srcs,srcs1) {
                let text = try element.text()
                let name = try element2.text()
                let url_string = self.urls[i]
                i = i + 1
                //print(url_string)
                //print(text)
                tweets.append(Tweet(author: name, tweet_text: text, url: url_string))
            }
            
            
        } catch let error {
            
        }
        
        
        tableView.reloadData()
    }
    
    
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweetcell", for: indexPath) as! TweetTableViewCell
    
        
        let tweet:Tweet = tweets[indexPath.row]
        //print(tweet.author!)
        cell.textLabel?.numberOfLines = 0
    
        cell.textLabel?.text = tweet.author + "\n" + tweet.tweet_text
    
        let show_image = defaults.bool(forKey: "Show_image")
    
    
        if (show_image == true){
            //print("display")
            if let url = URL(string:tweet.image_url){
                
                do{
                    
                    let data = try Data(contentsOf: url)
                    cell.imageView?.image = UIImage(data: data)
                    
                } catch let er{
                    
                }
            }
            
        } else{
            //print("not display")
            
        }
    
    
        return  cell
    }

}
