import UIKit
import SwiftSoup
import CoreData


let cache = NSCache<NSString, AnyObject>()
class TweetViewController: UIViewController, UITableViewDataSource {
    
    typealias Item = (text: String, html: String)
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var time_label: UILabel!
    
    @IBOutlet weak var search_btn: UIButton!
    
    var document: Document = Document.init("")
    
    var items: [NSManagedObject] = []
    var tweets: [Tweet] = []
    
    
    
    var urls: [String] = []
    
    let defaults = UserDefaults.standard
    
    var tweet_Timer: Timer!
    
    var time = 30
    
    var url = "https://twitter.com/"
    
    var username = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = ""
        
        tableView.dataSource = self
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tweet_obj")
        
        
        do {
            items = try managedContext.fetch(fetchRequest)
            
            for i in items {
                var name = i.value(forKey: "name") as! String
                var url  = i.value(forKey: "image_url")  as! String
                var text = i.value(forKey: "text")  as! String
                tweets.append(Tweet(author: name, tweet_text: text, url: url))
            }
            
            
        } catch{
            
        }
        
        let defaults = UserDefaults.standard
        
        urlTextField.text = defaults.string(forKey: "username")
        
        defaults.set(true, forKey: "cache")
        
        
        
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
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tweet_Timer.invalidate()
        
    }
    
    
    
    @objc func iterate(){
        time -= 1
        time_label.text = String(time)
        
        if time == 0 {
            time = 30
            
            url = "https://twitter.com/" + urlTextField.text!
            
            tweets.removeAll()
            
            tableView.reloadData()
            self.urls.removeAll()
            
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
            
            defaults.set(false, forKey: "cache")
        }
    }
    
    
    
    
    @IBAction func search(_ sender: UIButton) {
        
        time = 30
        
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
        
        if tweets.count == 0 {
            let alert = UIAlertController(title: "Некорректные данные", message: "Повторите попытку", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                }}))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        defaults.set(false, forKey: "cache")
        
    }
    
    
    
    func downloadHTML() {
        
        guard let url2 = URL(string: self.url ?? "") else {
            
            return
        }
        
        do {
            
            let html = try String.init(contentsOf: url2)
            document = try SwiftSoup.parse(html)
            
            let srcs: Elements = try document.select("p.tweet-text")
            let srcs1: Elements = try document.select("strong.u-textTruncate")
            let image_srcs: Elements = try document.select("img.js-action-profile-avatar")
            let usernames: Elements = try document.select("span.u-textTruncate")
            
            for us in usernames {
                username = try us.text()
            }
            
            
            let defaults = UserDefaults.standard
            
            defaults.set(username, forKey: "username")
            
            self.urlTextField.text = username
            
            for img in image_srcs {
                
                let url1 = try img.attr("src")
                self.urls.append(url1)
                
            }
            
            var i = 0
            
            for (element,element2) in zip(srcs,srcs1) {
                let text = try element.text()
                //print(text)
                let name = try element2.text()
                let url_string = self.urls[i]
                
                i = i + 1
                
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
        
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.text = tweet.author + "\n" + tweet.tweet_text
        
        let show_image = defaults.bool(forKey: "Show_image")
        
        let cache = defaults.bool(forKey: "cache")
        
        
        if (show_image == true){
            
            if cache == true {
                
                print("cached")
                let data = defaults.object(forKey: "image") as! NSData
                cell.imageView?.image = UIImage(data: data as Data)
                
            } else {
            
                if let url = URL(string:tweet.image_url){
                
                    do{
                    
                        let data = try Data(contentsOf: url)
                        cell.imageView?.image = UIImage(data: data)
                        let imagedata:NSData = UIImagePNGRepresentation(UIImage(data: data)!) as! NSData
                        defaults.set(data, forKey: "image")
                    
                    } catch let er{
                    
                    }
                }
            }
            
            
            
        }
        
        
        return  cell
    }
    
}
